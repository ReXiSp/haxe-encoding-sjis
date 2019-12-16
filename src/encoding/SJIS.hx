package encoding;

import extype.Error;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.ds.Either;
import haxe.iterators.StringIteratorUnicode;
import encoding.internal.*;

class SJIS {
    public static function encode(string:String):Bytes {
        final buffer = new BytesBuffer();
        for (codepoint in new StringIteratorUnicode(string)) {
            if (codepoint <= 0xff) {
                buffer.addByte(codepoint);
            } else {
                final code = UnicodeToSJISTable.get(codepoint).getOrElse("?".code);
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
                    return Left(new SJISDecodeError('Invalid codepoint: position=${pos}', pos));
                }
            }
        }

        return if (charbytes.isEmpty()) {
            Right(builder.toString());
        } else {
            Left(new SJISDecodeError("Unclosed SJIS bytes", pos));
        }
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
private abstract SJISCharBytes(Null<Int>) {
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
            SJIStoUnicodeTable.get(this).map(x -> CodePoint.of(x)).getOrElse(CodePoint.invalid());
        } else {
            null;
        }
    }
}

private abstract CodePoint(Int) {
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
