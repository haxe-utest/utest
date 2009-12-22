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
	public var getterReadonly(getValue, null) : String;
	public var setterReadonly(null, setValue) : String;
	public var setter(default, setSetterValue) : String;
	public var both(getValue, setValue) : String;
	public var getterDynamic(dynamic, null) : String;
	public var setterDynamic(null, dynamic) : String;

	private function getValue() {
		return value;
	}

	private function setValue(v) {
		value = v;
		return v;
	}

	private function setSetterValue(v) {
		setter = v;
		return v;
	}

	public function getSetterValue() {
		return setter;
	}
}