# ======================================================================
# Define options
# ======================================================================

set val(chan)       		Channel/WirelessChannel		;# channel type
set val(prop)       		Propagation/TwoRayGround	;# radio-propagation model
set val(netif)      		Phy/WirelessPhy   				;# network interface type
set val(mac)        		Mac/802_11		          	;# MAC type
set val(ifq)        		Queue/DropTail/PriQueue		;# interface queue type
set val(ll)         		LL												;# link layer type
set val(ant)        		Antenna/OmniAntenna				;# antenna model
set opt(x)              1200											;# X dimension of the topography
set opt(y)              1200											;# Y dimension of the topography
set val(ifqlen)         1000											;# max packet in ifq
set val(nn)             40												;# how many nodes are simulated
set val(seed)				    1.0				            		;# seed cbr
set val(adhocRouting)   AODV				        			;# routing protocol
set val(stop)           200				            		;# simulation time

# Modif this 
set val(dir)            "40node/"				          ;# directory name
set val(cp)			        "$val(dir)cbr.txt"			  ;# traffic filename
set val(sc)			        "$val(dir)scenario.txt"		;# mobility filename
set val(out_tracefd)		"$val(dir)scenario.tr"		;# output filename of tracefd
set val(out_namtrace)		"$val(dir)scenario.nam"	  ;# output filename of nametrace

# Energy modification
# src: https://www.nsnam.com/2012/11/energy-model-in-network-simulator-2-ns2.html
set val(energy_mod)         EnergyModel						;# energy model
set val(energy_init)        100                   ;# init val for energy
set val(tx_power)           1.65                  ;# energy consume for transmiting packet
set val(rx_power)           1.4                   ;# energy consume for receiving packet
set val(idle_power)         0.5                   ;# energy consume for idle
set val(sleep_power)        0.3                   ;# energy consume for sleep mode

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
set topo		[new Topography]
$topo load_flatgrid $opt(x) $opt(y)

# Create God
set god_ [create-god $val(nn)]

#global node setting
$ns_ node-config    -adhocRouting $val(adhocRouting) \
                    -llType $val(ll) \
                    -macType $val(mac) \
                    -ifqType $val(ifq) \
                    -ifqLen $val(ifqlen) \
                    -antType $val(ant) \
                    -propType $val(prop) \
                    -phyType $val(netif) \
                    -channelType $val(chan) \
                    -energyModel $val(energy_mod) \
                    -initialEnergy $val(energy_init) \
                    -txPower $val(tx_power) \
                    -rxPower $val(rx_power) \
                    -idlePower $val(idle_power) \
                    -sleepPower $val(sleep_power) \
                    -topoInstance $topo \
                    -agentTrace ON \
                    -routerTrace ON \
                    -macTrace ON \
                    -movementTrace ON

# 802.11p default parameters
Phy/WirelessPhy	set	RXThresh_ 5.57189e-11 ; #400m receiver sensitivity range
Phy/WirelessPhy set	CSThresh_ 5.57189e-11 ; #400m capture threshold  range

# 1m : 0.000192278
# 5m : 7.69113e-06
# 10m : 1.92278e-06
# 25m : 3.07645e-07
# 50m : 7.69113e-08
# 75m : 3.41828e-08
# 100m : 1.42681e-08
# 125m : 5.8442e-09
# 150m : 2.81838e-09
# 175m : 1.52129e-09
# 200m : 8.91754e-10
# 225m : 5.56717e-10
# 250m : 3.65262e-10
# 400m : 5.57189e-11
# 500m : 2.28289e-11
# 1000m : 1.42681e-12


#  Create the specified number of nodes [$val(nn)] and "attach" them
#  to the channel. 
#  plus random energy
#  src : http://slogix.in/how-to-find-residual-energy-of-the-nodes-in-ns2
for {set i 0} {$i < $val(nn)} {incr i} {
     if {$i < [expr $val(nn) - 2]} {
         set energy($i) [expr int(10 + rand()*40)];
	 $ns_ node-config    -adhocRouting $val(adhocRouting) \
         	             -llType $val(ll) \
                  	     -macType $val(mac) \
	                     -ifqType $val(ifq) \
	                     -ifqLen $val(ifqlen) \
	                     -antType $val(ant) \
	                     -propType $val(prop) \
	                     -phyType $val(netif) \
	                     -channelType $val(chan) \
	                     -energyModel $val(energy_mod) \
	                     -initialEnergy $energy($i) \
	                     -txPower $val(tx_power) \
	                     -rxPower $val(rx_power) \
	                     -idlePower $val(idle_power) \
	                     -sleepPower $val(sleep_power) \
	                     -topoInstance $topo \
	                     -agentTrace ON \
	                     -routerTrace ON \
	                     -macTrace ON \
	                     -movementTrace ON
         set node_($i) [$ns_ node]
         $node_($i) random-motion 0 ;# disable random motion
         $node_($i) color blue; #whatever you fill as long as color
         set E($i) $energy($i)
     } else {
	 $ns_ node-config    -adhocRouting $val(adhocRouting) \
	                     -llType $val(ll) \
	                     -macType $val(mac) \
	                     -ifqType $val(ifq) \
	                     -ifqLen $val(ifqlen) \
	                     -antType $val(ant) \
	                     -propType $val(prop) \
	                     -phyType $val(netif) \
	                     -channelType $val(chan) \
	                     -energyModel $val(energy_mod) \
	                     -initialEnergy $val(energy_init) \
	                     -txPower $val(tx_power) \
	                     -rxPower $val(rx_power) \
	                     -idlePower $val(idle_power) \
	                     -sleepPower $val(sleep_power) \
	                     -topoInstance $topo \
	                     -agentTrace ON \
	                     -routerTrace ON \
	                     -macTrace ON \
	                     -movementTrace ON
         set node_($i) [$ns_ node]
         $node_($i) random-motion 0 ;# disable random motion
         $node_($i) color black; #whatever you fill as long as color
     }
}

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