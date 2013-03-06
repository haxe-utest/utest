package lang.util;

#if haxe3
class SubImplementsDynamic extends ImplementsDynamic implements Dynamic<Int> 
#else
class SubImplementsDynamic extends ImplementsDynamic, implements Dynamic<Int> 
#end
{

}