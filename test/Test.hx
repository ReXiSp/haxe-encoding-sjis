using buddy.Should;
using haxe.ds.Either;

class Test extends buddy.SingleSuite {
    static function encodeTest(input: String, expectedFilename: String) {
        var expected: haxe.io.Bytes = sys.io.File.getBytes(expectedFilename);
        var output = JpText.Windows31J.encode(input);
        output.compare(expected).should().be(0);
    }
    static function decodeTest(inputFilename: String, expected: String) {
        var input: haxe.io.Bytes = sys.io.File.getBytes(inputFilename);
        JpText.Windows31J.decode(input).should().equal(Either.Right(expected));
    }

    public function new() {
        describe("encode from Windows31J to Unicode", {
            it("within ASCII", {
                encodeTest("hoge\n", "./testdata/ascii-sjis.txt");
            });
            it("fullwidth", {
                encodeTest("「」\n", "./testdata/fullwidth-sjis.txt");
            });
            it("HIRAGANA", {
                encodeTest("ほげ\n", "./testdata/hiragana-sjis.txt");
            });
        });
        describe("decode from Unicode to Windows31J", {
            it("within ASCII", {
                decodeTest("./testdata/ascii-sjis.txt", "hoge\n");
            });
            it("fullwidth", {
                decodeTest("./testdata/fullwidth-sjis.txt", "「」\n");
            });
            it("HIRAGANA", {
                decodeTest("./testdata/hiragana-sjis.txt", "ほげ\n");
            });
        });
        describe("Windows31J iterator", {
            it("only ascii", {
                var input = sys.io.File.getBytes("./testdata/ascii-sjis.txt");
                var expected: Array<Int> = [
                    'h'.code, 'o'.code, 'g'.code, 'e'.code, '\n'.code
                ];
                var i: Int = 0;
                for (codepoint in JpText.Windows31J.createIterator(input)) {
                    codepoint.should.equal(Either.Right(expected[i]));
                    i++;
                }
            });
            it("mixed", {
                var input = sys.io.File.getBytes("./testdata/mixed-sjis.txt");
                var expected: Array<Int> = [
                    'h'.code, 'o'.code, 'g'.code, 'e'.code,
                    '「'.code, '」'.code,
                    'ョ'.code, '\n'.code];
                var i: Int = 0;
                for (codepoint in JpText.Windows31J.createIterator(input)) {
                    codepoint.should.equal(Either.Right(expected[i]));
                    i++;
                }
            });
        });

        describe("JIS2004 validation", {
            it("ascii", {
                JpText.JIS2004.validate("Hello, JIS2004").should.equal(Either.Right(JpText.Unit.Dummy));
            });

            it("success", {
                JpText.JIS2004.validate("倶剥叱呑嘘妍屏并痩繋").should.equal(Either.Right(JpText.Unit.Dummy));
            });
        });
    }
}

