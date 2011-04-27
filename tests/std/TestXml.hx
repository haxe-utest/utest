package std;

import utest.Assert;

class TestXml {
	public function new(){}

	function checkExc( x : Xml, ?pos ) {
		Assert.raises( function() x.nodeName, pos );
		Assert.raises( function() x.nodeValue, pos );
		Assert.raises( function() x.attributes(), pos );
		Assert.raises( function() x.get("att"), pos );
		Assert.raises( function() x.exists("att"), pos );
	}

	function testBasic() {
		var x = Xml.parse('<a href="hello">World<b/></a>');

		Assert.equals( x.nodeType, Xml.Document );
		checkExc(x);

		x = x.firstChild();
		Assert.equals( x.nodeType, Xml.Element );

		// nodeName
		Assert.equals( x.nodeName, "a" );
		x.nodeName = "b";
		Assert.equals( x.nodeName, "b" );
		Assert.equals( x.toString(), '<b href="hello">World<b/></b>');

		// attributes
		Assert.equals( x.get("href"), "hello" );
		Assert.equals( x.get("other"), null );
		Assert.equals( x.exists("href"), true );
		Assert.equals( x.exists("other"), false );
		Assert.equals( Lambda.array({ iterator : x.attributes }).join("#"), "href" );
		x.remove("href");
		Assert.equals( Lambda.array({ iterator : x.attributes }).join("#"), "" );
		Assert.equals( x.toString(), '<b>World<b/></b>');

		// children
		Assert.equals( x.firstChild().nodeValue, "World" );
		Assert.equals( x.firstElement().nodeName, "b" );

		// errors
		Assert.raises( function() Xml.parse("<node>"), Dynamic );
	}

	function testFormat() {
		#if flash8
		// flash8 does not parse CDATA sections as PCDATA...
		Assert.equals( Xml.parse("<a><b><c/> <d/> \n <e/><![CDATA[<x>]]></b></a>").toString(), "<a><b><c/> <d/> \n <e/>&lt;x&gt;</b></a>" );
		#else
		Assert.equals( Xml.parse("<a><b><c/> <d/> \n <e/><![CDATA[<x>]]></b></a>").toString(), "<a><b><c/> <d/> \n <e/><![CDATA[<x>]]></b></a>" );
		#end
		#if (flash8 || php)
		Assert.equals( Xml.parse('"').toString(), '&quot;' ); // flash8 has bad habits of escaping entities
		#else
		Assert.equals( Xml.parse('"').toString(), '"' );
		#end
		#if flash9
		Assert.equals( Xml.parse('&quot; &lt; &gt;').toString(), '" &lt; &gt;' ); // some entities are resolved but not escaped on printing
		#else
		Assert.equals( Xml.parse('&quot; &lt; &gt;').toString(), '&quot; &lt; &gt;' );
		#end
	}

	function testComplex() {
		// this is showing some quirks with flash XML parser

		var header = '<?some header?>';
		var doctype = '<!DOCTYPE root SYSTEM "">';
		var comment = '<!--Comment-->';
		var xml = '<html><body><![CDATA[<a href="CDATA"/>&lt;]]></body></html>';

		#if flash8
		return; // too hard for him
		#end

		var x = Xml.parse(header + doctype + comment + xml);

		#if flash
		// doctype is well parsed but is not present in the parsed Xml (f8 and f9)
		doctype = '';
		#end

		Assert.equals( x.toString(), header + doctype + comment + xml);
	}

	function testWhitespaces() {
		// whitespaces
		var x = Xml.parse('<a> </a><b></b> \n <c/>');

		var childs = Lambda.array(x);

		Assert.equals( childs.length, 4 );

		var d = childs[2];
		Assert.equals( d.nodeType, Xml.PCData );
		Assert.equals( d.nodeValue, " \n " );

		var el = x.elements();
		var a = el.next();
		Assert.equals( a.firstChild().nodeValue, " ");
		var b = el.next();
		#if (flash || php)
		Assert.equals( b.firstChild(), null);
		Assert.equals( x.toString().split("\n").join("\\n"), '<a> </a><b/> \\n <c/>' );
		#else
		Assert.equals( b.firstChild().nodeValue, "");
		Assert.equals( x.toString().split("\n").join("\\n"), '<a> </a><b></b> \\n <c/>' );
		#end
		var c = el.next();
		Assert.equals( c.firstChild(), null);
	}

	function testCreate() {
		Assert.equals( Xml.createDocument().toString(), "");
		Assert.equals( Xml.createPCData("Hello").toString(), "Hello" );
		#if flash8
		// too hard for him
		return;
		#end

		Assert.equals( Xml.createCData("<x>").toString(), "<![CDATA[<x>]]>" );
		Assert.equals( Xml.createComment("Hello").toString(), "<!--Hello-->" );
		
		#if flash9
		Assert.equals( Xml.createProlog("XHTML").toString(), "<?XHTML ?>");
		// doctype is parsed but not printed
		Assert.equals( Xml.createDocType("XHTML").toString(), "" );
		#else
		Assert.equals( Xml.createProlog("XHTML").toString(), "<?XHTML?>");
		Assert.equals( Xml.createDocType("XHTML").toString(), "<!DOCTYPE XHTML>" );
		#end
		
		Assert.equals( Xml.parse("<?some header?>").firstChild().nodeType, Xml.Prolog );
		Assert.equals( Xml.parse("<?some header?>").firstChild().nodeValue, "some header" );
		Assert.equals( Xml.parse("<?some header?>").toString(), "<?some header?>" );
		Assert.equals( Xml.parse('<!DOCTYPE root SYSTEM "">').firstChild().nodeType, Xml.DocType );
		Assert.equals( Xml.parse('<!DOCTYPE root SYSTEM "">').firstChild().nodeValue, 'root SYSTEM ""' );
		Assert.equals( Xml.parse('<!DOCTYPE root SYSTEM "">').toString(), '<!DOCTYPE root SYSTEM "">' );
		Assert.equals( Xml.parse("<!--Hello-->").firstChild().nodeType, Xml.Comment );
		Assert.equals( Xml.parse("<!--Hello-->").firstChild().nodeValue, "Hello" );
		Assert.equals( Xml.parse("<!--Hello-->").toString(), "<!--Hello-->" );
		Assert.equals( Xml.parse("<![CDATA[He>llo]]>").firstChild().nodeType, Xml.CData );
		Assert.equals( Xml.parse("<![CDATA[He>llo]]>").firstChild().nodeValue, "He>llo" );
		Assert.equals( Xml.parse("<![CDATA[He>llo]]>").toString(), "<![CDATA[He>llo]]>" );
		Assert.equals( Xml.parse("Hello").firstChild().nodeType, Xml.PCData );
		Assert.equals( Xml.parse("Hello").firstChild().nodeValue, "Hello" );
		Assert.equals( Xml.parse("Hello").toString(), "Hello" );
		
		var c = Xml.createComment("Hello");
		Assert.equals( c.nodeValue, "Hello" );
		c.nodeValue = "Blabla";
		Assert.equals( c.nodeValue, "Blabla" );
		Assert.equals( c.toString(), "<!--Blabla-->");
		Assert.equals( Xml.parse("<![CDATA[Hello]]>").firstChild().nodeValue, "Hello" );
		var c = Xml.createCData("Hello");
		Assert.equals( c.nodeValue, "Hello" );
		c.nodeValue = "Blabla";
		Assert.equals( c.nodeValue, "Blabla" );
		Assert.equals( c.toString(), "<![CDATA[Blabla]]>");
		Assert.equals( Xml.createPCData("Hello").nodeValue, "Hello" );
	}

	function testNS() {
		var x = Xml.parse('<xhtml:br xmlns:xhtml="http://www.w3.org/1999/xhtml" xhtml:alt="test"><hello/></xhtml:br>').firstChild();
		Assert.equals( x.nodeType, Xml.Element );
		Assert.equals( x.nodeName, "xhtml:br" );
		Assert.isTrue( x.exists("xhtml:alt") );
		Assert.equals( x.get("xhtml:alt"), "test" );
		Assert.equals( x.get("xhtml:other"), null );
		x.set("xhtml:alt", "bye" );
		Assert.equals( x.get("xhtml:alt"), "bye" );

		var h = x.firstElement();
		Assert.equals( h.nodeName, "hello" );
		h.nodeName = "em";
		Assert.equals( h.nodeName, "em" );

		Assert.equals( Lambda.count({ iterator : callback(x.elementsNamed,"em") }), 1 );

		h.nodeName = "xhtml:em";

		Assert.equals( Lambda.count({ iterator : callback(x.elementsNamed,"xhtml:em") }), 1 );
		Assert.equals( Lambda.count({ iterator : callback(x.elementsNamed,"em") }), 0 );

		Assert.equals( h.nodeName, "xhtml:em" );
	}
/*
	public function testBase(){
		var x = Xml.parse("<coucou var=\"val\">Lala</coucou>");
		Assert.equals(Xml.Document,x.nodeType);
		Assert.equals("coucou",x.firstChild().nodeName);
		Assert.equals("Lala",x.firstChild().firstChild().nodeValue);
		Assert.equals("val",x.firstChild().get("var"));

		Assert.equals("var", x.firstChild().attributes().next());
#if !neko
		Assert.equals("<coucou var=\"val\">Lala</coucou>", x.toString());
#end
	}

	public function test2(){
		var x = Xml.parse("<coucou var=\"val\"><sub>Pouet !</sub>Lala</coucou>");

		try {
			Assert.isFalse(x.exists("pouet"));
			Assert.isTrue(false);
		}catch( e : Dynamic ){
		}

		Assert.equals("coucou",x.firstChild().nodeName);
		Assert.isTrue(x.firstChild().get("pouet")==null);
		Assert.isTrue(x.firstChild().exists("var"));
		Assert.equals("val",x.firstChild().get("var"));

		var i = 0;
		for( n in x.firstChild().elements() ){
			Assert.equals("sub",n.nodeName);
			i++;
		}
		Assert.equals(1,i);
		i = 0;
		for( n in x.firstChild() ){
			i++;
		}
		Assert.equals(2,i);
		i = 0;
		var a = x.firstChild().firstChild().attributes();
		Assert.isTrue(a != null);
		for( n in a ){
			i++;
		}
		Assert.equals(0,i);
	}

	public function test3(){
#if php
		var x = Xml.parse("<root><a/>lala<a/><b/><a/>pouet<c/><a/>pouet<c/><a/></root>");
		x = x.firstChild();
#else
		var x = Xml.parse("<a/>lala<a/><b/><a/>pouet<c/><a/>pouet<c/><a/>");
#end

		var i = 0;
		for( n in x.elementsNamed("a") ){
			i++;
		}
		Assert.equals(5,i);
	}

	// fail on Flash
	#if (flash8 || flash7 || neko)
	#elseif php
	public function testEmptyNode(){
		var s = "<p><x/><y></y></p>";
		var x = Xml.parse(s);
		Assert.equals("<p><x/><y/></p>", x.toString());
	}
	#else
	public function testEmptyNode(){
		var s = "<p><x/><y></y></p>";
		var x = Xml.parse(s);
		Assert.equals("<p><x/><y></y></p>" ,x.toString());
	}
	#end

	public function testModif(){

		var x = Xml.createElement("base");
		x.set("var","val");

		var y = Xml.createElement("temp");
		x.addChild(y);
		x.firstChild().nodeName = "un";

		var d = Xml.createElement("deux");
		x.addChild(d);

		#if (flash8 || flash7)
		Assert.equals("<base var=\"val\"><un /><deux /></base>",x.toString());
		#else
		Assert.equals("<base var=\"val\"><un/><deux/></base>",x.toString());
		#end
		var z = Xml.createElement("zero");
		x.insertChild(z,0);
		x.set("var","realval");

		#if (flash8 || flash7)
		Assert.equals("<base var=\"realval\"><zero /><un /><deux /></base>",x.toString());
		#else
		Assert.equals("<base var=\"realval\"><zero/><un/><deux/></base>",x.toString());
		#end

		var Assert.isTrue = Xml.createElement("trois");

		x.insertChild(Assert.isTrue,1);
		x.removeChild(y);

		#if (flash8 || flash7)
		Assert.equals("<base var=\"realval\"><zero /><trois /><deux /></base>",x.toString());
		#else
		Assert.equals("<base var=\"realval\"><zero/><trois/><deux/></base>",x.toString());
		#end

		var q = Xml.createElement("quatre");

		x.insertChild(q,2);
		x.removeChild(d);

		#if (flash8 || flash7)
		Assert.equals("<base var=\"realval\"><zero /><trois /><quatre /></base>",x.toString());
		#else
		Assert.equals("<base var=\"realval\"><zero/><trois/><quatre/></base>",x.toString());
		#end

		Assert.equals(true, x.removeChild(Assert.isTrue));

		#if (flash8 || flash7)
		Assert.equals("<base var=\"realval\"><zero /><quatre /></base>",x.toString());
		#else
		Assert.equals("<base var=\"realval\"><zero/><quatre/></base>",x.toString());
		#end
	}

	public function testFirstElement() {
		// in the original test, version was omitted, but version is not optional
		var x = Xml.parse("<?xml version=\"1.0\"?>     <pouet/>");
		Assert.equals("pouet",x.firstElement().nodeName);
	}

	// fail on Flash
	#if (flash8 || flash7)
	#else
	public function testAtt() {
#if php
		var x = Xml.parse("<p var=\"&quot;&amp;\"/>");
		var p = x.firstChild();
		Assert.equals("&quot;&amp;", p.get("var"));
#else
		var x = Xml.parse("<p var=\"&quot;&amp;&something;\"/>");
		var p = x.firstChild();
		Assert.equals("&quot;&amp;&something;", p.get("var"));
#end
	}

	public function testSpecials() {
		#if php
		var x = Xml.parse("<p var=\"&quot; &lt;&gt;&amp;\"><![CDATA[&lt;<COUCOU>]]>&lt;&gt;&amp;&quot;x</p>");
		#else
		var x = Xml.parse("<p var=\"&quot; &lt;&gt;&amp;\"><![CDATA[&lt;<COUCOU>]]>&lt;&gt;&amp;&quot;&</p>");
		#end
		var p = x.firstChild();
		Assert.equals("&quot; &lt;&gt;&amp;",p.get("var"));
		var a = new Array<Xml>();
		for ( c in p ) {
			a.push(c);
		}

		Assert.equals(Xml.CData,a[0].nodeType);

		Assert.equals("&lt;<COUCOU>",a[0].nodeValue);
		Assert.equals(Xml.PCData,a[1].nodeType);
		#if (php || neko)
		#else
		Assert.equals("&lt;&gt;&amp;&quot;&",a[1].nodeValue);
		Assert.equals("<p var=\"&quot; &lt;&gt;&amp;\"><![CDATA[&lt;<COUCOU>]]>&lt;&gt;&amp;&quot;&</p>",x.toString());
		#end
	}
	#end
*/
}
