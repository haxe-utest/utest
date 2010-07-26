/**
 * ...
 * @author Franco Ponticelli
 */

package lang;

import utest.Assert;

@classMeta("x")
class TestMeta
{
	@empty()
	@_int( -45)
	@complex([ { x : 0, y : "hello", z : -1.48, b : true, k : null } ])
	static var foo : Int;

	@new
	public function new();
	
	function fields( o : Dynamic ) {
		if( o == null ) return null;
		var fl = Reflect.fields(o);
		fl.sort(Reflect.compare);
		return fl.join("#");
	}
	
	public function testMeta() {
		var m = haxe.rtti.Meta.getType(E);
		Assert.equals("enumMeta", fields(m));
		Assert.isNull(m.enumMeta);

		var m = haxe.rtti.Meta.getType(TestMeta);
		Assert.equals( "classMeta", fields(m) );
		Assert.equals( "[x]", Std.string(m.classMeta) );

		var m = haxe.rtti.Meta.getFields(E);
		Assert.equals( "A#B", fields(m) );
		Assert.equals( "a", fields(m.A) );
		Assert.isNull( m.A.a );
		Assert.equals( "b", fields(m.B) );
		Assert.equals( "[0]", Std.string(m.B.b) );

		var m = haxe.rtti.Meta.getFields(TestMeta);
		Assert.equals( "_", fields(m) );
		Assert.equals( "new", fields(m._) );

		var m = haxe.rtti.Meta.getStatics(E);
		Assert.isNull( m );

		var m = haxe.rtti.Meta.getStatics(TestMeta);
		Assert.equals( "foo", fields(m) );
		Assert.equals( "_int#complex#empty", fields(m.foo) );
		Assert.isNull( m.foo.empty );
		Assert.equals( "[-45]", Std.string(m.foo._int) );
		var c : Dynamic = m.foo.complex[0][0];
		Assert.equals( "b#k#x#y#z", fields(c) );
		Assert.equals( 0, c.x);
		Assert.equals( "hello", c.y );
		Assert.equals( -1.48, c.z );
		Assert.isTrue( c.b );
		Assert.isNull( c.k );
	}
}

@enumMeta private enum E {
	@a A;
	@b(0) B;
}
