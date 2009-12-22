package std.neutral.utils;

#if neko
import neko.db.Object;
import neko.db.Manager;
#elseif php
import php.db.Object;
import php.db.Manager;
#end

class TestVO extends Object
{
    public var id : Int;
    public var test_string: String;
    public var test_date : Date;
    static inline var TABLE_NAME = "test";
    public static var manager = new Manager<TestVO>(TestVO);

}