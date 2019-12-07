# ======================================================================
# Define options
# ======================================================================

set val(chan)       		Channel/WirelessChannel		;# channel type
set val(prop)       		Propagation/TwoRayGround	;# radio-propagation model
set val(netif)      		Phy/WirelessPhy			      ;# network interface type
set val(mac)        		Mac/802_11		  	        ;# MAC type
set val(ifq)        		Queue/DropTail/PriQueue		;# interface queue type
set val(ll)         		LL				                ;# link layer type
set val(ant)        		Antenna/OmniAntenna		    ;# antenna model
set opt(x)              1200   				            ;# X dimension of the topography
set opt(y)              1200   				            ;# Y dimension of the topography
set val(ifqlen)         1000				              ;# max packet in ifq
set val(nn)             40		                    ;# how many nodes are simulated
set val(seed)			      1.0				                ;
set val(adhocRouting)   AODV				              ;# routing protocol
set val(stop)           200				                ;# simulation time

# Modify this 
set val(dir)            "40node/"				          ;# directory name
set val(cp)			        "$val(dir)cbr.txt"			  ;# traffic filename
set val(sc)			        "$val(dir)scenario.txt"		;# mobility filename
set val(out_tracefd)		"$val(dir)scenario.tr"		;# output filename of tracefd
set val(out_namtrace)		"$val(dir)scenario.nam"	  ;# output filename of nametrace

# =====================================================================
# Main Program
# ======================================================================
# Initialize Global Variables
# create simulator instance
set ns_		[new Simulator]

# setup topography object
set topo	[new Topography]

# create trace object for ns and nam
set tracefd			[open $val(out_tracefd) w]
set namtrace    [open $val(out_namtrace) w]

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# set up topology object
set topo				[new Topography]
$topo load_flatgrid $opt(x) $opt(y)

# Create God
set god_ [create-god $val(nn)]

#global node setting
$ns_ node-config  -adhocRouting $val(adhocRouting) \
                  -llType $val(ll) \
                  -macType $val(mac) \
                  -ifqType $val(ifq) \
                  -ifqLen $val(ifqlen) \
                  -antType $val(ant) \
                  -propType $val(prop) \
                  -phyType $val(netif) \
		              -channelType $val(chan) \
		              -topoInstance $topo \
		              -agentTrace ON \
		              -routerTrace ON \
		              -macTrace ON \
		              -movementTrace ON \
								 
###

# 802.11p default parameters
Phy/WirelessPhy	set	RXThresh_ 5.57189e-11 ; #400m
Phy/WirelessPhy set	CSThresh_ 5.57189e-11 ; #400m

###
#  Create the specified number of nodes [$val(nn)] and "attach" them
#  to the channel. 
for {set i 0} {$i < $val(nn)} {incr i} {
		set node_($i) [$ns_ node]
		$node_($i) random-motion 0 ;# disable random motion
}

# Define node movement model
puts "Loading connection pattern..."
source $val(cp)

# Define traffic model
puts "Loading scenario file..."
source $val(sc)

# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

#$ns_ at  $val(stop)	"stop"
$ns_ at  $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"

puts $tracefd "M 0.0 nn $val(nn) x $opt(x) y $opt(y) rp $val(adhocRouting)"
puts $tracefd "M 0.0 sc $val(sc) cp $val(cp) seed $val(seed)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"

puts "Starting Simulation..."
$ns_ run
