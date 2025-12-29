var vfr_code = [ 7, 0, 0, 0 ];

var tx_digits = [
	props.globals.getNode("/instrumentation/transponder/inputs/digit[3]", 1),
	props.globals.getNode("/instrumentation/transponder/inputs/digit[2]", 1),
	props.globals.getNode("/instrumentation/transponder/inputs/digit[1]", 1),
	props.globals.getNode("/instrumentation/transponder/inputs/digit[0]", 1),
];
var ind_digits = [
	props.globals.initNode("/instrumentation/transponder/display/digit[3]", vfr_code[0], "INT"),
	props.globals.initNode("/instrumentation/transponder/display/digit[2]", vfr_code[1], "INT"),
	props.globals.initNode("/instrumentation/transponder/display/digit[1]", vfr_code[2], "INT"),
	props.globals.initNode("/instrumentation/transponder/display/digit[0]", vfr_code[3], "INT"),
];
var volts = props.globals.getNode("/systems/electrical/outputs/transponder", 1);

var input_active = [
	props.globals.initNode("/instrumentation/transponder/display/input-active[0]", 0, "BOOL"),
	props.globals.initNode("/instrumentation/transponder/display/input-active[1]", 0, "BOOL"),
	props.globals.initNode("/instrumentation/transponder/display/input-active[2]", 0, "BOOL"),
	props.globals.initNode("/instrumentation/transponder/display/input-active[3]", 0, "BOOL"),
];

var input_state = -1;	# -1 = no current input, 0 - 3 = digits modified (left to right)

var num_press = func( x ){
	if( volts.getDoubleValue() < 9 ) return;
	
	input_state += 1;
	reset_input_timer.restart( 7.0 );
	
	ind_digits[ input_state ].setIntValue( x );
	
	if( input_state == 3 ){
		for( var i = 0; i <= 3; i += 1 ){
			tx_digits[ i ].setIntValue( ind_digits[ i ].getIntValue() );
		}
		input_state = -1;
	}
	
	forindex( var i; input_active ){
		if( input_state != -1 and i == ( input_state + 1 ) ){
			input_active[ i ].setBoolValue( 1 );
		} else {
			input_active[ i ].setBoolValue( 0 );
		}
	}
};

forindex( var i; tx_digits ){
	setlistener( tx_digits[ i ], func{
		if( tx_digits[ i ].getIntValue() != ind_digits[ i ].getIntValue() and input_state == -1 ){
			ind_digits[ i ].setIntValue( tx_digits[ i ].getIntValue() );
		}
	});
}

var reset_input = func{	
	input_state = -1;
	foreach( var el; input_active ){
		el.setBoolValue( 0 );
	}
}

var reset_input_timer = maketimer( 7.0, reset_input );
reset_input_timer.simulatedTime = 1;
reset_input_timer.singleShot = 1;
