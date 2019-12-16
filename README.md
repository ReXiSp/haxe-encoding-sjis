# ShiftJIS encoder/decoder for Haxe 

## Requirement
+ Haxe 4.0+

## Tested platforms
* JavaScript
* NekoVM

## Install
```
haxelib install encoding-sjis
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
