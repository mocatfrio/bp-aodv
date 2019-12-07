# 3. Simulation

## 3.1 Requirements
These tools are default from **ns-allinone-2.35**, so you don't need to install it again. 

* **setdest** (command: `~/ns-allinone-2.35/ns-2.35/indep-utils/cmu-scen-gen/setdest/setdest`)
* **cbrgen** (command: `ns ~/ns-allinone-2.35/ns-2.35/indep-utils/cmu-scen-gen/cbrgen.tcl`)

## 3.2 Steps
### 3.2.1 Preparation

1. First, create aliases for executing tools that will be used to create scenarios in AODV. Alias are usually used to customize commands that are too long in Ubuntu. 
   * Open .bashrc, .zshrc, etc (shell script that runs every time a new shell opens). In this case, I use .zshrc script.
        ```bash
        nano ~/.zshrc
        ```
    * Add these lines:
        ```bash
        alias setdest="~/ns-allinone-2.35/ns-2.35/indep-utils/cmu-scen-gen/setdest/setdest"
        alias cbrgen="ns ~/ns-allinone-2.35/ns-2.35/indep-utils/cmu-scen-gen/cbrgen.tcl"
        ```
    * Execute the script:
        ```bash
        source ~/.zshrc
        ```
                                                       
2. Make new directories to save the scenarios file. For example, we want create a 40 node scenario:
    ```bash
    mkdir -p ~/ns2/scenario/40node
    ```

3. Test the aliases created:
    * **Setdest tool** is used to generate the positions of nodes, their moving speed, and moving directions. Check the syntax of setdest by typing this command:
        ```bash
        setdest
        ```
        ```bash
        usage:

        <original 1999 CMU version (version 1)>
        ./setdest -v <1> -n <nodes> -p <pause time> -M <max speed> -t <simulation time> -x <max X> -y <max Y>

        OR
        <modified 2003 U.Michigan version (version 2)>
        ./setdest -v <2> -n <nodes> -s <speed type> -m <min speed> -M <max speed> -t <simulation time> -P <pause type> -p <pause time> -x <max X> -y <max Y>
        ```
    * **Cbrgen tool** is used to generate CBR (Constant Bit Rate) packet. Check the syntax of cbrgen by typing this command:
        ```bash
        cbrgen
        ```
        ```bash
        usage: cbrgen.tcl [-type cbr|tcp] [-nn nodes] [-seed seed] [-mc connections] [-rate rate]
        ```

### 3.2.2 Create Scenario
1. Change to the desired scenario directory. In this case we will make **40node** scenario.
    ```bash
    cd ~/ns2/scenario/40node
    ```
2. Create a map that contains several nodes, then generate the positions of nodes, their moving speed, and moving directions using **Setdest tool**.
    * Generate intermediate dynamic nodes:
        ```bash  
        setdest -v 2 -n 38 -s 1 -m 20 -M 40 -t 100 -P 1 -p 1 -x 500 -y 500 > dynamic.txt

        # p.s.
        # version of setdest: 2
        # number of intermediate nodes: 38
        # speed type: 1
        # min speed: 20
        # max speed: 40
        # simulation time: 100
        # pause type: 1
        # pause time: 1
        # Area: 500 x 500
        # Output file: dynamic.txt (you can change the filename as you want)
        ```
        > Check the file using `nano` or `cat` command.
    * Define two static nodes as source and destination node. Actually you can specify the position of source and destination node as you want. Example: 
        ```bash
        echo -e '$node_(38) set X_ 0\n$node_(38) set Y_ 451.65\n$node_(38) set Z_ 0\n$node_(39) set X_ 451.65\n$node_(39) set Y_ 0\n$node_(39) set Z_ 0' > static.txt
        ```
    * Merge `dynamic.txt` and `static.txt` files.
        ```bash
        (cat dynamic.txt && cat static.txt) > scenario.txt

        # delete unused files
        rm dynamic.txt static.txt
        ```

3. Generate CBR packet using **Cbrgen tool**.
    ```bash  
    cbrgen -type cbr -nn 40 -seed 1 -mc 1 -rate 1.0 > cbr.txt

    # p.s.
    # packet type: CBR
    # number of nodes: 40
    # seed: 1
    # connection: 1
    # rate: 1
    ```
    Change the source and destination agent using `sed` command:
    ```bash
    sed -i 's/$node_(1)/$node_(38)/g' cbr.txt # replace node 1 to node 38
    sed -i 's/$node_(2)/$node_(39)/g' cbr.txt # replace node 2 to node 39
    ```

4. Download this scenario scripts written in TCL language.
    * [Scenario for AODV without energy](scenario/scen.tcl)
    * [Scenario for AODV with energy](scenario/scen-energy.tcl)
    
    Don't forget to set several variables below according to yours:
    ```tcl
    # Modify this 
    set val(dir)            "40node/"               ;# directory name
    set val(cp)             "$val(dir)cbr.txt"      ;# traffic filename
    set val(sc)             "$val(dir)scenario.txt"	;# mobility filename
    set val(out_tracefd)	"$val(dir)scenario.tr"	;# output filename of tracefd
    set val(out_namtrace)	"$val(dir)scenario.nam"	;# output filename of nametrace
    ```

### 3.2.3 Simulation

1. Run the created scenario using NS-2 by typing this command:
    ```bash
    ns scen.tcl
    ```
    Several lines will appear as below:
    ```bash
    ╭─mocatfrio@jK ~/ns2/bp-aodv/scenario  ‹master*› 
    ╰─$ ns scen.tcl
    num_nodes is set 40
    warning: Please use -channel as shown in tcl/ex/wireless-mitf.tcl
    INITIALIZE THE LIST xListHead
    Loading connection pattern...
    Loading scenario file...
    Starting Simulation...
    channel.cc:sendUp - Calc highestAntennaZ_ and distCST_
    highestAntennaZ_ = 1.5,  distCST_ = 400.0
    SORTING LISTS ...DONE!
    NS EXITING...
    ```
    After the simulation finished, output files (`scenario.tr` and `scenario.nam`) will appear in the `40node/` directory.

### 3.2.4 Evaluation
After doing a simulation, then we must evaluate it.

1. Create an evaluation AWK file (AWK is a programming language designed for text processing and typically used as a data extraction and reporting tool). This AWK file is used for reading the `scenario.tr` file as the simulation output. You can download the evaluation AWK file [here](scenario/eval.awk).
2. Make sure that AWK has been installed by typing command `awk -V`.
    * If not, install it by typing `sudo apt-get install gawk`
3. Run the AWK script.
    ```bash
    awk -f eval.awk scenario.tr
    ```
    The output will be more readable as below:
    ```bash
    ========================= 
    Packet Delivery Ratio 
    ========================= 
    Packet SendLine 	= 195 
    Packet RecvLine 	= 126 
    Packet Loss 		= 69 
    Packet ForwardLine	= 241 
    Packet Delivery Ratio 	= 0.6462 

    Topology Control 	= 0 
    Routing Packets 	= 0 
    Route Request Send 	= 0 
    Route Request Forward 	= 0 

    ========================= 
    Average End-to-end Delay  
    ========================= 
    Avg End-to-End Delay 	= 1329.9 ms 

    ========================== 
    Copy this to excel sheets!  
    ========================== 
    195	126	0.6462	69	1329.9 ms	0	0	0
    ```
4. You can use `nam` to open the `scenario.nam` output file.
    ```bash
    nam scenario.nam
    ```


