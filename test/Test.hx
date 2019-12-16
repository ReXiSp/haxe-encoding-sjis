import encoding.SJIS;
using buddy.Should;
using haxe.ds.Either;

class Test extends buddy.SingleSuite {
    static function encodeTest(input: String, expectedFilename: String) {
        var expected: haxe.io.Bytes = sys.io.File.getBytes(expectedFilename);
        var output = SJIS.encode(input);
        output.compare(expected).should().be(0);
    }
    
    static function decodeTest(inputFilename: String, expected: String) {
        var input: haxe.io.Bytes = sys.io.File.getBytes(inputFilename);
        SJIS.decode(input).should().equal(Either.Right(expected));
    }

    public function new() {
        describe("Unicode -> SJIS", {
            it("should encode ASCII", {
                encodeTest("hoge\n", "./testdata/ascii-sjis.txt");
            });
            
            it("should encode fullwidth", {
                encodeTest("「」\n", "./testdata/fullwidth-sjis.txt");
            });
            
            it("should encode HIRAGANA", {
                encodeTest("ほげ\n", "./testdata/hiragana-sjis.txt");
            });
        });
        
        describe("SJIS -> Unicode", {
            it("should decode ASCII", {
                decodeTest("./testdata/ascii-sjis.txt", "hoge\n");
            });
            
            it("should decode fullwidth", {
                decodeTest("./testdata/fullwidth-sjis.txt", "「」\n");
            });
            
            it("should decode HIRAGANA", {
                decodeTest("./testdata/hiragana-sjis.txt", "ほげ\n");
            });
        });
    }
}

