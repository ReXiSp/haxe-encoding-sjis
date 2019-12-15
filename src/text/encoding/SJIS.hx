package text.encoding;

import extype.Error;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.ds.Either;
import haxe.iterators.StringIteratorUnicode;
import text.encoding.internal.Windows31JTable;

class SJIS {
    public static function encode(string:String):Bytes {
        final table = Windows31JTable.unicodeToWindows31j();

        final buffer = new BytesBuffer();
        for (codepoint in new StringIteratorUnicode(string)) {
            final code = table.get(codepoint);
            if (code == null) {
                buffer.addByte("?".code);
            } else if (code <= 0xff) {
                buffer.addByte(code);
            } else {
                // assume little endian
                buffer.addByte((code >> 8) & 0xff);
                buffer.addByte(code & 0xff);
            }
        }
        return buffer.getBytes();
    }
    
    public static function decode(bytes:Bytes):Either<SJISDecodeError, String> {
        final builder = new StringBuf();
        
        var pos = 0;
        var charbytes = new SJISCharBytes();
        while (pos < bytes.length) {
            charbytes = charbytes.append(bytes.get(pos++));
            
            final codepoint = charbytes.toCodePoint();
            if (codepoint != null) {
                if (codepoint.isValid()) {
                    builder.add(String.fromCharCode(codepoint.get()));
                    charbytes = new SJISCharBytes();
                } else {
                    return Left(new SJISDecodeError("Invalid", pos));
                }
            }
        }

        return if (charbytes.isEmpty()) {
            Right(builder.toString());
        } else {
            Left(new SJISDecodeError("Invalid", pos));
        }
    }
}

abstract SJISCharBytes(Null<Int>) {
    public inline function new(?value:Int) {
        this = value;
    }

    public inline function isEmpty():Bool {
        return this == null;
    }

    public inline function append(byte:Int):SJISCharBytes {
        return if (isEmpty()) {
            new SJISCharBytes(byte);
        } else {
            new SJISCharBytes((this << 8) + byte);
        }
    }

    public inline function toCodePoint():Null<CodePoint> {
        return if (isEmpty()) {
            null;
        } else if (this <= 0x7F) {
            CodePoint.of(this);
        } else if (this > 0xFF) {
            final cp = Windows31JTable.windows31jToUnicode().get(this);
            (cp != null) ? CodePoint.of(cp) : CodePoint.invalid();
        } else {
            null;
        }
    }
}

abstract CodePoint(Int) {
    inline function new(value:Int) {
        this = value;
    }

    public inline function get():Int {
        return this;
    }

    public inline function isValid():Bool {
        return this >= 0;
    }

    public inline static function of(value:Int):CodePoint {
        return new CodePoint(value);
    }

    public inline static function invalid():CodePoint {
        return new CodePoint(-1);
    }
}

class SJISDecodeError extends Error {
    public var position(default, null):Int;
    
    public function new(message:String, pos:Int) {
        super();
        this.message = message;
        this.position = pos;
    }
}