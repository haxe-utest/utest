package lang.util;

class PropertyClass {
	public function new() {
		readonly  = "readonly";
		writeonly = "writeonly";
		excessive = "excessive";
		nopoint   = "nopoint";
		value     = "value";
		setter    = "setter";
	}

	public var readonly(default, null) : String;
	public var writeonly(null, default) : String;

	public function setReadonly(v : String)  { readonly = v; }
	public function getWriteonly() { return writeonly; }

	public var excessive(default, default) : String;
	public var nopoint(null, null) : String;

	public function getNopoint() { return nopoint; }
	public function setNopoint(v) { nopoint = v; }

	private var value : String;
	public var getterReadonly(get_getterReadonly, null) : String;
	@:isVar public var setterReadonly(null, set_setterReadonly) : String;
	public var setter(default, set_setter) : String;
	public var both(get_both, set_both) : String;
	public var getterDynamic(dynamic, null) : String;
	public var setterDynamic(null, dynamic) : String;
	
	private function get_getterReadonly() { return get_value(); }
	private function get_both() { return get_value(); }
	private function set_both(v) { return set_value(v); }
	private function set_setterReadonly(v) { return set_value(v); }
	private function get_value() {
		return value;
	}

	private function set_value(v) {
		value = v;
		return v;
	}

	private function set_setter(v) {
		setter = v;
		return v;
	}

	public function get_setterValue() {
		return setter;
	}
}