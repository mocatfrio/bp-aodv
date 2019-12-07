# BP-AODV
Blackhole Protected AODV for Network Design and Audit Course 2019

> Group 3:
> * 05111540000043 - Hafara Firdausi
> * 05111540000031 - Aulia T. Nururrahmah
> * 05111540007001 - Nabe Gedalia Razafindrobelina

This simple documentation created by Mocatfrio 😽

## Requirements
1. Debian based-Linux OS (Ubuntu, Linux Mint, etc)
2. Basic CLI skill

## 1. [NS2 Installation](install-ns2.md)

## 2. Implementation
### 2.1 Add Blackhole 

1. Before modifying the original AODV code, create a backup by typing `mv ~/ns-allinone-2.35/ns-2.35/aodv ~/ns-allinone-2.35/ns-2.35/aodv-ori`.
2. Add a blackhole mechanism by modifying AODV code in ns-2.35 (follow [this tutorial](http://www.jgyan.com/ns2/blackhole%20attack%20simulation%20in%20ns2.php)). After that, do a simple simulation using 25 nodes and [blackhole scenario](scenario/blackhole.tcl) to compare AODV-ori and AODV-blackhole, and here is the result! You can find the full results [here](scenario/25node)

    ![](img/ss2.png)

    Based on our experiment, AODV-blackhole has a smaller PDR (Packet Delivery Ratio) than the AODV-ori. Hence, we implement BP-AODV to solve the blackhole problem.

### Important!
1. After modifying AODV code, don't forget to always recompile NS-2
    ```bash
    cd ~/ns-allinone-2.35/ns-2.35
    sudo make clean
    sudo make
    sudo make install
    ```
2. Here's some bash scripts that will easier your life. Create these files in the `~/ns-allinone-2.35/ns-2.35` directory.
    * **Switcher** is used to switch from the AODV-ori code to AODV-blackhole, and vice versa.
        ```bash
        #!/bin/bash

        if [ $1 -eq 1 ] ; then
            # switch from aodv ori to aodv bp
            mv ~/ns-allinone-2.35/ns-2.35/aodv ~/ns-allinone-2.35/ns-2.35/aodv-ori
            mv ~/ns-allinone-2.35/ns-2.35/aodv-bp ~/ns-allinone-2.35/ns-2.35/aodv
            exit 1
        else
            # switch from aodv-bp to aodv ori
            mv ~/ns-allinone-2.35/ns-2.35/aodv ~/ns-allinone-2.35/ns-2.35/aodv-bp
            mv ~/ns-allinone-2.35/ns-2.35/aodv-ori ~/ns-allinone-2.35/ns-2.35/aodv
            exit 1
        fi  
        ```
        ```bash
        bash switch.sh 1
        bash switch.sh 2
        ```

    * **Compiler** is used to recompile NS-2
        ```bash
        #!/bin/bash
        
        make clean
        make 
        make install
        ```
        ```bash
        # dont forget to use SUDO
        sudo bash make.sh
        ```

## 3. [Simulation and Evaluation](simulation.md)
