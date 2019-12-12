import haxe.iterators.StringIteratorUnicode;
import haxe.ds.Either;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;

class Windows31JIterator {
    var bytes: Bytes;
    var pos: Int;

    public function new(bytes: Bytes) {
        this.bytes = bytes;
        this.pos = 0;
    }
    public function hasNext() {
        return pos < bytes.length;
    }
    public function next() {
        var table = Windows31JTable.windows31jToUnicode();

        if (!hasNext())
            return null;
        var w31char = bytes.get(pos);
        pos++;
        if (table.get(w31char) != null) {
            return Either.Right(table.get(w31char));
        }

        if (!hasNext())
            return null;
        w31char = w31char << 8 | bytes.get(pos);
        pos++;
        if (table.get(w31char) != null) {
            return Either.Right(table.get(w31char));
        }

        return Either.Left(new Error(pos, 'invalid Windows31J charactor'));
    }
}

class Windows31J {
    public static function encode(string: String): Bytes {
        var buffer = new BytesBuffer();
        var table = Windows31JTable.unicodeToWindows31j();
        for (codepoint in StringIteratorUnicode.unicodeIterator(string)) {
            var code = table.get(codepoint);
            if (code == null)
                return null;
            else if (code & 0xff00 != 0) { // 2byte char
                // assume little endian
                buffer.addByte((code >> 8) & 0xff);
                buffer.addByte(code & 0xff);
            } else { // 1byte char
                buffer.addByte(code);
            }
        }
        return buffer.getBytes();
    }
    public static function decode(bytes: Bytes): Either<Error, String> {
        var result = "";
        for (codepoint in createIterator(bytes)) {
            switch codepoint {
            case Either.Right(codepoint):
                result += String.fromCharCode(codepoint);
            case Either.Left(error):
                return Either.Left(error);
            }
        }
        return Either.Right(result);
    }

    // "Windows-31J Bytes" to "CodePoint Iterator"
    public static function createIterator(bytes: Bytes): Iterator<Either<Error, Int>> {
        return new Windows31JIterator(bytes);
    }
}

enum Unit {Dummy;}

class JIS2004 {
    public static function validate(string: String): Either<Error, Unit> {
        var table = JIS2004Table.create();
        var pos = 0;
        for (codepoint in StringIteratorUnicode.unicodeIterator(string)) {
            if (!table.exists(codepoint)) {
                return Either.Left(new Error(pos, 'invalid JIS2004 charactor'));
            }
            pos++;
        }
        return Either.Right(Unit.Dummy);
    }
}

class Error {
    public final position: Int;
    public final message: String;

    public function new(pos: Int, message: String) {
        this.position = pos;
        this.message = message;
    }
}



