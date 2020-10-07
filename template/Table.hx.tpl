// DO NOT EDIT!
package encoding.internal;

import extype.Nullable;
import extype.map.IntMap;

class ::name:: {
    public static inline function get(code:Int):Nullable<Int> {
        return getTable().get(code);
    }

    static var _table:IntMap<Int>;
    static function getTable():IntMap<Int> {
        if (_table == null) {
            _table = new IntMap();
            ::foreach rules::_table.set(::key::, ::value::);
            ::end::
        }
        return _table;
    }
}
