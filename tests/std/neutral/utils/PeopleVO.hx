package std.neutral.utils;

#if php
import php.db.Object;
import php.db.Manager;
#else
import neko.db.Object;
import neko.db.Manager;
#end

class PeopleVO extends Object {
   static function RELATIONS() {
       return [{ prop : "role", key : "role_id", manager : RoleVO.manager }];
   }
   public var id : Int;
   public var name : String;
   private var role_id: Int;
   public var role(dynamic,dynamic) : RoleVO;
   static inline var TABLE_NAME = "people";
   public static var manager = new PeopleVOManager();

}

class PeopleVOManager extends Manager<PeopleVO> {
   public function new() {
       super(PeopleVO);
   }
}

class RoleVO extends Object {
   public var id : Int;
   public var name : String;
   static inline var TABLE_NAME = "roles";
   public static var manager = new Manager<RoleVO>(RoleVO);
}