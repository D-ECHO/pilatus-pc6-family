#	This simulates a BENDIX/KING KCS-55A Compass System

var slave_sw = props.globals.initNode("/instrumentation/ka51b/slave-switch", 0, "BOOL");
var slew_sw = props.globals.initNode("/instrumentation/ka51b/slew-switch", 0, "INT");

var slave = 0;
var slew = 0;

setprop("/instrumentation/magnetic-slaving-transmitter/serviceable", 1);
var mag_hdg = props.globals.getNode("/instrumentation/magnetic-slaving-transmitter/indicated-heading-deg", 1);

var hdg_offset = props.globals.getNode("/instrumentation/heading-indicator-dg/offset-deg", 1);
var hdg_ind = props.globals.getNode("/instrumentation/heading-indicator-dg/indicated-heading-deg", 1);

var dt = props.globals.getNode("/sim/time/delta-sec", 1);

setlistener( slew_sw, func{
	if( slave ) return;
	
	slew = slew_sw.getIntValue();
	
	if( slew != 0 ){
		slew_loop_timer.start();
	} else {
		slew_loop_timer.stop();
	}
});

setlistener( slave_sw, func{
	slave = slave_sw.getBoolValue();
});

var slew_loop = func{
	if( !slave and slew != 0 ){
		hdg_offset.setDoubleValue( hdg_offset.getDoubleValue() + 5 * slew * dt.getDoubleValue() );
	}
}

var slew_loop_timer = maketimer( 0.0, slew_loop );
slew_loop_timer.simulatedTime = 1;
