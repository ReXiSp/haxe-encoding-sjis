import sys.io.File;
using StringTools;

class TableGenerator {
    public static function main() {
        final sjisToUnicodeName = "SJIStoUnicodeTable";
        final sjisToUnicodeRules = [];
        final unicodeToSjisName = "UnicodeToSJISTable";
        final unicodeToSjisRules = [];

        for (row in parseCsv("table.csv")) {
            final sjis = row[0].trim();
            final unicode = row[1].trim();
            
            // skip ASCII
            if (Std.parseInt(sjis) <= 0x7F) continue;
            // skip UNDEFINED
            if (unicode.length <= 0) continue;

            sjisToUnicodeRules.push({key: sjis, value: unicode});
            unicodeToSjisRules.push({key: unicode, value: sjis});
        }

        final template = new haxe.Template(File.getContent("template/Table.hx.tpl"));

        File.saveContent('src/text/encoding/internal/$sjisToUnicodeName.hx', template.execute({
            name: sjisToUnicodeName,
            rules: sjisToUnicodeRules
        }));
        File.saveContent('src/text/encoding/internal/$unicodeToSjisName.hx', template.execute({
            name: unicodeToSjisName,
            rules: unicodeToSjisRules
        }));
    }

    static function parseCsv(path:String):Array<Array<String>> {
        final result = [];

        final bytes = File.getBytes(path);
        var pos = 0;
        var row = [];
        var cell = new StringBuf();

        function closeCell() {
            row.push(cell.toString());
            cell = new StringBuf();
        }

        function closeRow() {
            closeCell();
            switch (row) {
                case [] | [""]: //nop
                case _: result.push(row);
            }
            row = [];
        }

        while (pos < bytes.length) {
            final char = bytes.get(pos++);
            switch (char) {
                case "\n".code:
                    closeRow();
                case ",".code:
                    closeCell();
                case _:
                    cell.addChar(char);
            }
        }

        closeRow();

        return result;
    }
}
