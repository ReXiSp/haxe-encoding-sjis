# ShiftJIS encoder/decoder for Haxe 

## Requirement
+ Haxe 4.0+
+ Git (*To install*)

## Tested platforms
* C++

## Install
```
haxelib git encoding-sjis https://github.com/ReXiSp/haxe-encoding-sjis
```

## Usage

```
var sjisBytes = SJIS.encode("こんにちわ！");

var result = SJIS.decode(sjisBytes);
switch (result) {
    case Right(text): trace(text);
    case Left(error): trace(error);
}
```
