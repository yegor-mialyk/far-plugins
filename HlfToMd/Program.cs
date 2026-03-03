using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

var helpFile = args.Length > 0 ? args[0] : "FarEng.hlf";

if (!File.Exists(helpFile))
{
    Console.WriteLine($"Input file not found: {helpFile}");
    return;
}

try
{
    var outputFile = Path.ChangeExtension(helpFile, ".md");

    var converter = new FarHelpMdConverter(helpFile);

    converter.Convert();

    converter.SaveToFile(outputFile);
}
catch (Exception ex)
{
    Console.WriteLine($"Conversion failed: {ex.Message}");
}

public partial class FarHelpMdConverter
{
    private readonly ICollection<string> _help;
    private bool _parAttached;
    private bool _inCode;
    private bool _inTable;

    public FarHelpMdConverter(string helpFile)
    {
        _help = File.ReadAllLines(helpFile, new UTF8Encoding(false));
    }

    public Dictionary<string, string> Aliases { get; } = [];

    public Dictionary<string, string> Options { get; } = [];

    public Dictionary<string, (int Order, string Text)> Sections { get; } = [];

    public string? Language { get; set; }

    public void Convert()
    {
        var order = 0;
        var sb = new StringBuilder();
        var pendingLeftCell = string.Empty;
        var pendingRightCell = string.Empty;
        var hasPendingTableRow = false;
        var pendingKeyOnLeft = false;
        var appendContinuationToRight = false;
        var tableGapPending = false;
        bool? tableKeyOnLeft = null;
        string? section = null;

        foreach (var line in _help)
        {
            if (string.IsNullOrWhiteSpace(line))
            {
                _parAttached = false;

                if (_inTable)
                {
                    FlushPendingTableRow();
                    tableGapPending = true;
                }
                else
                {
                    CloseCode();
                }

                continue;
            }

            var normalizedLine = RemoveStartPosChars(line);

            if (_inTable && hasPendingTableRow && _parAttached &&
                IsDeepIndentedContinuation(line, pendingKeyOnLeft))
            {
                var continuation = normalizedLine.Trim();

                if (continuation.Length != 0)
                {
                    var joinInline = StartsWithLowercaseWord(continuation);
                    var appendToLeft = pendingKeyOnLeft && IsStandaloneHashedKeyFragment(continuation);
                    continuation = ProcessInlineCell(continuation);
                    var separator = joinInline ? " " : "<br>";

                    if (appendToLeft)
                        pendingLeftCell = $"{pendingLeftCell}{separator}{continuation}";
                    else if (appendContinuationToRight)
                        pendingRightCell = $"{pendingRightCell}{separator}{continuation}";
                    else
                        pendingLeftCell = $"{pendingLeftCell}{separator}{continuation}";

                    continue;
                }
            }

            if (_inTable && hasPendingTableRow && _parAttached &&
                ShouldTreatAsKeyPrefixContinuation(normalizedLine, pendingKeyOnLeft))
            {
                var continuation = normalizedLine.Trim();
                var joinInline = StartsWithLowercaseWord(continuation);
                var appendToLeft = pendingKeyOnLeft && IsStandaloneHashedKeyFragment(continuation);
                continuation = ProcessInlineCell(continuation);
                var separator = joinInline ? " " : "<br>";

                if (appendToLeft)
                    pendingLeftCell = $"{pendingLeftCell}{separator}{continuation}";
                else if (appendContinuationToRight)
                    pendingRightCell = $"{pendingRightCell}{separator}{continuation}";
                else
                    pendingLeftCell = $"{pendingLeftCell}{separator}{continuation}";

                continue;
            }

            var hasPreParsedTableRow = false;
            var preParsedLeftCell = string.Empty;
            var preParsedRightCell = string.Empty;
            var preParsedKeyOnLeft = false;

            if (tableGapPending)
            {
                if (TryParseTableRow(normalizedLine, out preParsedLeftCell, out preParsedRightCell,
                    out preParsedKeyOnLeft, allowSingleSpaceSeparator: _inTable))
                {
                    hasPreParsedTableRow = true;
                }
                else
                {
                    CloseTable();
                }

                tableGapPending = false;
            }

            if (line.StartsWith(".Language", StringComparison.OrdinalIgnoreCase))
            {
                var parts = line.Split(['=', ','], 2,
                    StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries);

                if (parts.Length >= 2)
                    Language = parts[1];

                continue;
            }

            if (line.StartsWith(".Options", StringComparison.OrdinalIgnoreCase))
            {
                var parts = line.Split(['=', ' ', '\t'], 3,
                    StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries);

                if (parts.Length >= 3)
                    Options[parts[1]] = parts[2];

                continue;
            }

            if (line.StartsWith('@') && line.Contains('=') && !line.StartsWith("@="))
            {
                CloseTable();
                var parts = line.Split('=', 2, StringSplitOptions.TrimEntries);

                Aliases[parts[0].Trim('@')] = parts[1].Trim('@');

                continue;
            }

            if (line.StartsWith('@') && !line.StartsWith("@="))
            {
                CloseTable();
                CloseCode();

                if (sb.Length > 0 && section is not null)
                {
                    Sections[section] = (order++, sb.ToString());
                    sb.Clear();
                }

                section = line.Trim('@');

                sb.AppendLine($"<a id=\"{section}\"></a>");
                sb.AppendLine();

                _parAttached = false;
                continue;
            }

            if (line.StartsWith('$'))
            {
                CloseTable();
                CloseCode();

                sb.Append(Sections.Count != 0 ? "## " : "# ");
                sb.AppendLine($"{line.Trim('$', '#', '^', ' ', '\t')}");

                _parAttached = false;
                continue;
            }

            if (line == "@=" && !_inCode)
            {
                CloseTable();
                if (!_parAttached)
                    sb.AppendLine();

                sb.AppendLine("---");

                _parAttached = false;
                continue;
            }

            if (!_inCode && (hasPreParsedTableRow || TryParseTableRow(normalizedLine, out preParsedLeftCell,
                    out preParsedRightCell, out preParsedKeyOnLeft, allowSingleSpaceSeparator: _inTable)))
            {
                var leftCell = preParsedLeftCell;
                var rightCell = preParsedRightCell;
                var keyOnLeft = preParsedKeyOnLeft;

                if (_inTable && tableKeyOnLeft.HasValue && tableKeyOnLeft.Value != keyOnLeft)
                    CloseTable();

                if (!_inTable)
                {
                    if (!_parAttached)
                        sb.AppendLine();

                    sb.AppendLine("| | |");
                    sb.AppendLine("|---|---|");
                    _inTable = true;
                    tableKeyOnLeft = keyOnLeft;
                }

                if (CanMergeWithPendingRow(leftCell, rightCell, keyOnLeft))
                {
                    pendingLeftCell = $"{pendingLeftCell}<br>{ProcessInlineCell(leftCell)}";
                    pendingRightCell = $"{pendingRightCell} {ProcessInlineCell(rightCell)}";
                    appendContinuationToRight = keyOnLeft;
                    _parAttached = true;

                    continue;
                }

                FlushPendingTableRow();

                leftCell = ProcessInlineCell(leftCell);
                rightCell = ProcessInlineCell(rightCell);

                pendingLeftCell = leftCell;
                pendingRightCell = rightCell;
                hasPendingTableRow = true;
                pendingKeyOnLeft = keyOnLeft;

                appendContinuationToRight = keyOnLeft;

                _parAttached = true;

                continue;
            }

            if (_inTable && hasPendingTableRow && _parAttached)
            {
                var continuation = normalizedLine.Trim();

                if (continuation.Length != 0)
                {
                    var joinInline = StartsWithLowercaseWord(continuation);
                    var appendToLeft = pendingKeyOnLeft && IsStandaloneHashedKeyFragment(continuation);
                    continuation = ProcessInlineCell(continuation);
                    var separator = joinInline ? " " : "<br>";

                    if (appendToLeft)
                        pendingLeftCell = $"{pendingLeftCell}{separator}{continuation}";
                    else if (appendContinuationToRight)
                        pendingRightCell = $"{pendingRightCell}{separator}{continuation}";
                    else
                        pendingLeftCell = $"{pendingLeftCell}{separator}{continuation}";

                    continue;
                }
            }

            CloseTable();

            if (line.StartsWith(' ') && !_parAttached && !_inCode)
                sb.AppendLine();
            else if (line.StartsWith(' ') && _parAttached && !_inCode)
            {
                sb.Length -= Environment.NewLine.Length;
                sb.AppendLine("<br>");
            }

            var ss = normalizedLine.Trim();
            var hasPseudographic = ContainsPseudographicSymbols(ss);

            if (!_inCode && hasPseudographic)
            {
                if (_parAttached)
                    sb.AppendLine();

                sb.AppendLine("```");

                _inCode = true;
            }
            else if (_inCode && !hasPseudographic)
            {
                sb.AppendLine("```");
                sb.AppendLine();

                _inCode = false;
            }

            if (ss.StartsWith("* "))
                ss = $"- {ss[2..]}";

            if (ss.StartsWith("^#"))
                ss = $"{ss[1..]}";

            ss = ReplaceLinks(ProcessSpecialChars(ss));

            sb.AppendLine(ss);

            _parAttached = !ss.StartsWith("### ", StringComparison.Ordinal);
        }

        CloseCode();
        CloseTable();

        if (sb.Length > 0 && section is not null)
            Sections[section] = (order, sb.ToString());

        void CloseCode()
        {
            if (!_inCode)
                return;

            sb.AppendLine("```");
            _inCode = false;
        }

        void CloseTable()
        {
            if (!_inTable)
                return;

            FlushPendingTableRow();

            sb.AppendLine();
            _inTable = false;
            tableKeyOnLeft = null;
            _parAttached = false;
        }

        void FlushPendingTableRow()
        {
            if (!hasPendingTableRow)
                return;

            sb.AppendLine($"| {pendingLeftCell} | {pendingRightCell} |");

            pendingLeftCell = string.Empty;
            pendingRightCell = string.Empty;
            appendContinuationToRight = false;
            hasPendingTableRow = false;
            pendingKeyOnLeft = false;
        }

        bool CanMergeWithPendingRow(string nextLeftCell, string nextRightCell, bool nextKeyOnLeft)
        {
            if (!hasPendingTableRow || pendingKeyOnLeft != nextKeyOnLeft)
                return false;

            // Wrapped dialog options in HLF often split both columns across lines.
            // Merge only for key-on-left rows where the next key chunk starts lower-case.
            if (!nextKeyOnLeft)
                return false;

            return StartsWithLowercaseWord(nextLeftCell) && nextRightCell.Length != 0;
        }

        static bool StartsWithLowercaseWord(string value)
        {
            var s = value.TrimStart();

            if (s.Length == 0)
                return false;

            if (s[0] == '#')
                return TryGetFirstLetter(s, 0, out var hashedLetter) && char.IsLower(hashedLetter);

            if (s[0] == '~')
                return TryGetFirstLetter(s, 1, out var tildeLetter) && char.IsLower(tildeLetter);

            if (s.StartsWith("(~", StringComparison.Ordinal))
                return TryGetFirstLetter(s, 2, out var parenTildeLetter) && char.IsLower(parenTildeLetter);

            return char.IsLower(s[0]);

            static bool TryGetFirstLetter(string text, int start, out char letter)
            {
                for (var i = start; i < text.Length; i++)
                {
                    if (!char.IsLetter(text[i]))
                        continue;

                    letter = text[i];
                    return true;
                }

                letter = '\0';
                return false;
            }
        }

        static bool IsDeepIndentedContinuation(string sourceLine, bool keyOnLeft)
        {
            if (!keyOnLeft || sourceLine.Length == 0)
                return false;

            var leadingWhitespace = 0;

            while (leadingWhitespace < sourceLine.Length && char.IsWhiteSpace(sourceLine[leadingWhitespace]))
                leadingWhitespace++;

            // In FAR HLF tables, wrapped right-column lines are deeply indented.
            return leadingWhitespace >= 20;
        }

        static bool IsStandaloneHashedKeyFragment(string value)
        {
            return HashedKeyFragmentRegex().IsMatch(value.Trim());
        }

        static bool ShouldTreatAsKeyPrefixContinuation(string value, bool keyOnLeft)
        {
            if (keyOnLeft)
                return false;

            return KeyPrefixContinuationRegex().IsMatch(value.Trim());
        }

        string ProcessInlineCell(string cell)
        {
            var prevAttached = _parAttached;
            _parAttached = true;

            var processed = ReplaceLinks(ProcessSpecialChars(cell));

            _parAttached = prevAttached;
            return processed;
        }
    }

    private static bool TryParseTableRow(string line, out string leftCell, out string rightCell,
        out bool keyOnLeft, bool allowSingleSpaceSeparator = false)
    {
        var match = ForwardTableRowRegex().Match(line);
        keyOnLeft = false;

        if (!match.Success)
        {
            match = ReversedTableRowRegex().Match(line);
            keyOnLeft = match.Success;
        }

        if (!match.Success && allowSingleSpaceSeparator)
        {
            match = ForwardSingleSpaceTableRowRegex().Match(line);

            if (!match.Success)
            {
                match = ReversedSingleSpaceTableRowRegex().Match(line);
                keyOnLeft = match.Success;
            }
        }

        if (!match.Success)
        {
            leftCell = string.Empty;
            rightCell = string.Empty;
            keyOnLeft = false;

            return false;
        }

        leftCell = match.Groups["left"].Value.Trim();
        rightCell = match.Groups["right"].Value.Trim();

        return leftCell.Length != 0 && rightCell.Length != 0;
    }


    private string ReplaceLinks(string s)
    {
        return LinkRegex().Replace(s, m =>
        {
            if (!m.Groups[1].Success)
                return m.Value switch
                {
                    "@@" => "@",
                    "~~" => "~",
                    _ => m.Value
                };

            var text = m.Groups[1].Value.Replace("~~", @"\~");
            var section = m.Groups[2].Value.Replace("@@", "@");

            if (Aliases.TryGetValue(section, out var alias))
                section = alias;

            return $"[{text}](#{section})";
        });
    }

    private static readonly int[] Ansi256CubeSteps = [0, 95, 135, 175, 215, 255];

    private static readonly string[] ConsoleColors =
    [
        "#000000", "#000080", "#008000", "#008080",
        "#800000", "#800080", "#808000", "#c0c0c0",
        "#808080", "#0000ff", "#00ff00", "#00ffff",
        "#ff0000", "#ff00ff", "#ffff00", "#ffffff"
    ];

    private static bool IsHex(char c) =>
        c is >= '0' and <= '9' or >= 'a' and <= 'f' or >= 'A' and <= 'F';

    private static bool IsHexByte(string s, int index) =>
        index + 1 < s.Length && IsHex(s[index]) && IsHex(s[index + 1]);

    private static string Ansi256ToHex(int colorIndex)
    {
        switch (colorIndex)
        {
            case < 0 or > 255:
                return "#000000";
            case < 16:
                return colorIndex switch
                {
                    0 => "#000000",
                    1 => "#800000",
                    2 => "#008000",
                    3 => "#808000",
                    4 => "#000080",
                    5 => "#800080",
                    6 => "#008080",
                    7 => "#c0c0c0",
                    8 => "#808080",
                    9 => "#ff0000",
                    10 => "#00ff00",
                    11 => "#ffff00",
                    12 => "#0000ff",
                    13 => "#ff00ff",
                    14 => "#00ffff",
                    _ => "#ffffff"
                };
            case < 232:
            {
                var n = colorIndex - 16;
                var r = n / 36;
                var g = n % 36 / 6;
                var b = n % 6;
                var steps = Ansi256CubeSteps;

                return string.Create(CultureInfo.InvariantCulture, $"#{steps[r]:X2}{steps[g]:X2}{steps[b]:X2}")
                    .ToLowerInvariant();
            }
            default:
            {
                var gray = 8 + (colorIndex - 232) * 10;

                return string.Create(CultureInfo.InvariantCulture, $"#{gray:X2}{gray:X2}{gray:X2}")
                    .ToLowerInvariant();
            }
        }
    }

    private string ProcessSpecialChars(string s)
    {
        var colorChar = Options.GetValueOrDefault("CtrlColorChar");
        var cc = string.IsNullOrEmpty(colorChar) ? '\\' : colorChar[0];

        var result = new StringBuilder();
        var colorCloseBraces = 0;
        var i = 0;

        while (i < s.Length)
        {
            if (s[i] == '#')
            {
                var end = -1;

                for (var j = i + 1; j < s.Length; j++)
                {
                    if (s[j] != '#')
                        continue;

                    if (j + 1 < s.Length && s[j + 1] == '#')
                    {
                        j++;
                        continue;
                    }

                    end = j;
                    break;
                }

                if (end == i + 1)
                {
                    result.Append('#');
                    i += 2;
                    continue;
                }

                if (end > i)
                {
                    CloseColor();

                    var code = new StringBuilder();
                    var hasTick = false;

                    for (var j = i + 1; j < end;)
                    {
                        if (s[j] == '#' && j + 1 < end && s[j + 1] == '#')
                        {
                            code.Append('#');
                            j += 2;

                            continue;
                        }

                        if (s[j] == cc)
                        {
                            j++;

                            if (j < end)
                                if (s[j] == cc)
                                {
                                    code.Append(cc);
                                    j++;

                                    continue;
                                }

                            code.Append(cc);
                        }
                        else
                        {
                            if (s[j] == '`')
                                hasTick = true;

                            code.Append(s[j++]);
                        }
                    }

                    var ss = code.ToString();
                    if (IsKeyCommand(ss) || ss.StartsWith('-') || ss.StartsWith('[') || ss.Contains('!')
                        || ss.Contains('\\') || ss.Contains('%') || ss.Contains('|') || ss.Contains('^')
                        || ss.Contains('&') || ss.Contains('<') || ss.Contains('>') || ss.Contains('~')
                        || ss.Contains('@') || ss.Contains('=') || ss.Contains('$')
                        || ss.Contains('`')
                        || ss.Contains('{') || ss.Contains('}') || ss.Contains('.')
                        || ss.Contains(',') || ss.Contains(';') || ss.Contains('?') || ss.Contains('*'))
                    {
                        if (hasTick)
                            result.Append($"``{(ss[^1] == '`' || ss[0] == '`' ? $" {ss} " : ss)}``");
                        else
                            result.Append($"`{ss}`");
                    }
                    else if (result.Length > 0 || end < s.Length - 1 || _parAttached || _inTable)
                    {
                        result.Append("**");
                        result.Append(ss.Replace("*", @"\*"));
                        result.Append("**");
                    }
                    else
                        result.Append($"### {ss}");

                    i = end + 1;

                    continue;
                }
            }

            if (s[i] == cc)
            {
                i++;

                if (IsHexByte(s, i))
                {
                    var fg = int.Parse(s.AsSpan(i, 2), NumberStyles.HexNumber) & 0x0F;
                    var bg = int.Parse(s.AsSpan(i, 2), NumberStyles.HexNumber) >> 4;

                    var fgColor = ConsoleColors[fg];
                    var bgColor = ConsoleColors[bg];

                    CloseColor();

                    OpenColor(fgColor, bgColor);

                    i += 2;

                    continue;
                }

                if (i < s.Length)
                    switch (s[i])
                    {
                        case '(' when i + 4 < s.Length && IsHex(s[i + 1]) && s[i + 2] == ':' &&
                            IsHex(s[i + 3]) && s[i + 4] == ')':
                        {
                            var fg = int.Parse(s.AsSpan(i + 1, 1), NumberStyles.HexNumber) & 0x0F;
                            var bg = int.Parse(s.AsSpan(i + 3, 1), NumberStyles.HexNumber) & 0x0F;

                            OpenColor(ConsoleColors[fg], ConsoleColors[bg]);

                            i += 5;

                            continue;
                        }
                        case '(' when i + 5 < s.Length && IsHex(s[i + 1]) && s[i + 2] == ':' &&
                            IsHex(s[i + 3]) && s[i + 4] == ':':
                        {
                            var styleEnd = i + 5;
                            while (styleEnd < s.Length && s[styleEnd] != ')')
                                styleEnd++;

                            if (styleEnd > i + 5 && styleEnd < s.Length)
                            {
                                var fg = int.Parse(s.AsSpan(i + 1, 1), NumberStyles.HexNumber) & 0x0F;
                                var bg = int.Parse(s.AsSpan(i + 3, 1), NumberStyles.HexNumber) & 0x0F;
                                var style = s[(i + 5)..styleEnd];

                                OpenColor(ConsoleColors[fg], ConsoleColors[bg], style);

                                i = styleEnd + 1;

                                continue;
                            }

                            break;
                        }
                        case '(' when i + 6 < s.Length && IsHexByte(s, i + 1) && s[i + 3] == ':' &&
                            IsHexByte(s, i + 4) && s[i + 6] == ')':
                        {
                            var fg = int.Parse(s.AsSpan(i + 1, 2), NumberStyles.HexNumber);
                            var bg = int.Parse(s.AsSpan(i + 4, 2), NumberStyles.HexNumber);

                            OpenColor(Ansi256ToHex(fg), Ansi256ToHex(bg));

                            i += 7;

                            continue;
                        }
                        case '(' when i + 4 < s.Length && s[i + 1] == ':' && IsHexByte(s, i + 2) &&
                            s[i + 4] == ')':
                        {
                            var bg = int.Parse(s.AsSpan(i + 2, 2), NumberStyles.HexNumber);

                            OpenColor(null, Ansi256ToHex(bg));

                            i += 5;

                            continue;
                        }
                        case '(' when i + 11 < s.Length && s[i + 1] == 'T' &&
                            IsHex(s[i + 2]) && s[i + 3] == ':' && s[i + 4] == 'T' &&
                            IsHexByte(s, i + 5) && IsHexByte(s, i + 7) && IsHexByte(s, i + 9) &&
                            s[i + 11] == ')':
                        {
                            var fg = int.Parse(s.AsSpan(i + 2, 1), NumberStyles.HexNumber) & 0x0F;
                            var fgColor = ConsoleColors[fg];
                            var bgColor = string.Concat("#", s.AsSpan(i + 5, 6));

                            OpenColor(fgColor, bgColor);
                            i += 12;

                            continue;
                        }
                        case '(' when i + 16 < s.Length && s[i + 1] == 'T' &&
                            IsHexByte(s, i + 2) && IsHexByte(s, i + 4) && IsHexByte(s, i + 6) &&
                            s[i + 8] == ':' && s[i + 9] == 'T' &&
                            IsHexByte(s, i + 10) && IsHexByte(s, i + 12) && IsHexByte(s, i + 14) &&
                            s[i + 16] == ')':
                        {
                            var fgColor = string.Concat("#", s.AsSpan(i + 2, 6));
                            var bgColor = string.Concat("#", s.AsSpan(i + 10, 6));

                            OpenColor(fgColor, bgColor);
                            i += 17;

                            continue;
                        }
                        case '-':
                            CloseColor();
                            i++;

                            continue;
                        case '\\':
                            result.Append(colorCloseBraces != 0 ? @"\textbackslash " : @"\\");
                            i++;

                            continue;
                    }

                i--;
            }

            if (colorCloseBraces != 0)
                result.Append(s[i] switch
                {
                    '{' => @"\{",
                    '}' => @"\}",
                    '$' => @"\$",
                    '#' => @"\#",
                    '_' => @"\_",
                    '^' => @"\^",
                    ' ' => @"\ ",
                    '\\' => @"\textbackslash ",
                    _ => s[i]
                });
            else if (_inCode)
                result.Append(s[i]);
            else
                result.Append(s[i] switch
                {
                    '<' => @"\<",
                    '>' => @"\>",
                    '$' => @"\$",
                    '|' => @"\|",
                    '`' => @"\`",
                    '*' => @"\*",
                    '_' => @"\_",
                    _ => s[i]
                });

            i++;
        }

        CloseColor();

        return result.ToString();

        void OpenColor(string? fgColor, string bgColor, string? style = null)
        {
            CloseColor();

            var styleMd = style switch
            {
                "bold" => @"\textbf",
                "italic" => @"\textit",
                _ => @"\text"
            };

            if (fgColor is null)
                result.Append($@"${{\colorbox{{{bgColor}}}{{{styleMd}{{");
            else
                result.Append($@"${{\colorbox{{{bgColor}}}{{\color{{{fgColor}}}{styleMd}{{");

            colorCloseBraces = 3;
        }

        void CloseColor()
        {
            if (colorCloseBraces == 0)
                return;

            result.Append('}', colorCloseBraces);
            result.Append('$');

            colorCloseBraces = 0;
        }
    }

    private static bool IsKeyCommand(string s)
    {
        if (string.IsNullOrWhiteSpace(s))
            return false;

        if (Exceptions.Contains(s))
            return true;

        if (IsSingleKeyCommand(s))
            return true;

        var commands = CommandSeparatorRegex().Split(s)
            .Select(c => c.Trim())
            .ToArray();

        return commands.All(command => !string.IsNullOrWhiteSpace(command) && IsSingleKeyCommand(command));
    }

    private static bool IsSingleKeyCommand(string s)
    {
        s = s.Trim();
        s = OptionalModifierRegex().Replace(s, "$1+");

        var parts = KeySeparatorRegex().Split(s);

        for (var i = 0; i < parts.Length; i++)
        {
            var token = parts[i].Trim();

            if (token.Length == 0)
                return false;

            if (parts.Length == 1 && AllowedModifiers.Contains(token))
                return true;

            var isLast = i == parts.Length - 1;

            if (!isLast)
            {
                if (EscapedKeyRegex().IsMatch(token) || !AllowedModifiers.Contains(token))
                    return false;

                continue;
            }

            if (EscapedKeyRegex().IsMatch(token))
                token = token[1..^1].Trim();

            if (IsSupportedKey(token))
                return true;

            return AllowedModifiers.Contains(token) &&
                parts.All(p => AllowedModifiers.Contains(p.Trim()));
        }

        return false;
    }

    private static bool IsSupportedKey(string token)
    {
        if (token.Length == 0)
            return false;

        if (MouseKeys.Contains(token))
            return true;

        if (SpecialKeys.Contains(token))
            return true;

        if (FunctionKeyRegex().IsMatch(token))
            return true;

        if (NumpadKeyRegex().IsMatch(token))
            return true;

        if (GraySymbolKeyRegex().IsMatch(token))
            return true;

        if (KeyRangeRegex().IsMatch(token))
            return true;

        return token.Length == 1 && !char.IsWhiteSpace(token[0]);
    }

    private string RemoveStartPosChars(string s)
    {
        var startPosChar = Options.GetValueOrDefault("CtrlStartPosChar");

        if (!string.IsNullOrEmpty(startPosChar))
            s = s.Replace(startPosChar, string.Empty);

        return s;
    }

    private static bool ContainsPseudographicSymbols(string s)
    {
        return s.Any(c => c is >= '\u2500' and <= '\u257F' or
            >= '\u2580' and <= '\u259F' or >= '\u23A0' and <= '\u23FF');
    }

    public void SaveToFile(string filePath)
    {
        var output = Sections.Values.OrderBy(s => s.Order)
            .Select(s => s.Text);

        File.WriteAllLines(filePath, output, new UTF8Encoding(false));
    }

    private static readonly HashSet<string> AllowedModifiers =
        new(StringComparer.OrdinalIgnoreCase)
        {
            "Ctrl", "Shift", "Alt", "RAlt", "LAlt", "Win", "LWin", "RWin",
            "LeftCtrl", "RightCtrl", "LeftShift", "RightShift", "LeftAlt", "RightAlt",
            "LeftWin", "RightWin", "LCtrl", "RCtrl", "LShift", "RShift"
        };

    private static readonly HashSet<string> SpecialKeys =
        new(StringComparer.OrdinalIgnoreCase)
        {
            "BS", "Backspace", "Tab", "Enter", "Return", "Esc", "Escape", "Space", "Spacebar",
            "Insert", "Ins", "Del", "Plus", "Minus", "Subtract", "Multiply", "Divide",

            "Up", "Down", "Left", "Right", "Arrow", "Arrows", "Cursor", "Cursor key", "Cursor keys",
            "PgUp", "PageUp", "PgDn", "PageDown", "Home", "End", "gray cursor keys", "gray keys",

            "CapsLock", "NumLock", "ScrollLock", "PrintScreen", "PrtSc", "Pause", "Break",
            "Apps", "Menu", "ContextMenu",

            "Right mouse button", "Left mouse button", "doubleclick"
        };

    private static readonly HashSet<string> MouseKeys =
        new(StringComparer.OrdinalIgnoreCase)
        {
            "MsLClick", "MsRClick", "MsMClick",
            "MsX1Click", "MsX2Click", "MsX3Click", "MsX4Click",
            "MsWheelUp", "MsWheelDown", "MsWheelLeft", "MsWheelRight",

            "XButton1", "XButton2", "Mouse4", "Mouse5", "Button4", "Button5"
        };

    private static readonly HashSet<string> Exceptions =
        new(StringComparer.OrdinalIgnoreCase)
        {
            "tree3.far", "secpol.msc", "FarMenu.Ini", "0x", ",.;:"
        };

    [GeneratedRegex("~~|@@|~((?:[^~]|~~)*)~@((?:[^@]|@@)*)@")]
    private static partial Regex LinkRegex();

    [GeneratedRegex(@"^#(?:[^#]|##)+#(?:\s*/\s*#(?:[^#]|##)+#)*$")]
    private static partial Regex HashedKeyFragmentRegex();

    [GeneratedRegex(@"^#(?:[^#]|##)+#\s+[a-z]")]
    private static partial Regex KeyPrefixContinuationRegex();

    [GeneratedRegex(@"^\s*(?<left>.+?)\s{2,}(?<right>#(?:[^#]|##)+#(?:\s*/\s*#(?:[^#]|##)+#)*)\s*$")]
    private static partial Regex ForwardTableRowRegex();

    [GeneratedRegex(@"^\s*(?<left>#(?:[^#]|##)+#(?:\s*/\s*#(?:[^#]|##)+#)*)\s{2,}(?<right>.+?)\s*$")]
    private static partial Regex ReversedTableRowRegex();

    [GeneratedRegex(@"^\s*(?<left>.+?)\s(?!\s)(?<right>#(?:[^#]|##)+#(?:\s*/\s*#(?:[^#]|##)+#)*)\s*$")]
    private static partial Regex ForwardSingleSpaceTableRowRegex();

    [GeneratedRegex(@"^\s*(?<left>#(?:[^#]|##)+#(?:\s*/\s*#(?:[^#]|##)+#)*)\s(?!\s)(?<right>.+?)\s*$")]
    private static partial Regex ReversedSingleSpaceTableRowRegex();

    [GeneratedRegex(",(?=(?:[^<]*<[^>]*>)*[^<]*$)")]
    private static partial Regex CommandSeparatorRegex();

    [GeneratedRegex(@"(?<=\S)\+(?=\S)(?=(?:[^<]*<[^>]*>)*[^<]*$)")]
    private static partial Regex KeySeparatorRegex();

    [GeneratedRegex("^<[^<>]+>$")]
    private static partial Regex EscapedKeyRegex();

    [GeneratedRegex(@"\[(\w+)\+\]", RegexOptions.IgnoreCase)]
    private static partial Regex OptionalModifierRegex();

    [GeneratedRegex("^F(?:[1-9]|1[0-9]|2[0-9])$", RegexOptions.IgnoreCase)]
    private static partial Regex FunctionKeyRegex();

    [GeneratedRegex("^NumPad[0-9]$", RegexOptions.IgnoreCase)]
    private static partial Regex NumpadKeyRegex();

    [GeneratedRegex(@"^Gray\s+[\p{P}\p{S}]$", RegexOptions.IgnoreCase)]
    private static partial Regex GraySymbolKeyRegex();

    [GeneratedRegex(@"^[0-9](?:\.\.\.|\u2026)[0-9]$")]
    private static partial Regex KeyRangeRegex();
}
