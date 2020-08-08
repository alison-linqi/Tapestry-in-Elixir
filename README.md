What is working: 
We use Genserver as the actor model in our network. 
First, we input the number of nodes that is included in the network and the number of requests each node needs to make.
Then we call the build_topology method to build each node. The name of each node is encrypted under SHA-1 algorithm, thus generating its own unique ID.
Because we used SHA-1(base 16) to generate node ID. Each node's neighbor table consists of 40 rows and 16 columns. 
When a new node is inserted to the network, it will multicast to the existing nodes in the network and find its neighbors. Correspondingly, each existing node will decide whether or not it should add the new coming node to its neighbor table based on its prefix.
For the starting node a, when routing to a destination node, a will look up its neighbor table to find the next node it should hop to, if the destination node is the same as the next node, the searching process is finished. Otherwise, it will continue routing.
The number of hops from node a to destination node d is written into a list, hoplist. Each time each node sends a request. After the searching finished, the maximum hop is selected from the hoplist. 
After one round terminated, the max hop will be compared to the last round to find the larger one. After all rounds of sending requests terminated, the max hop is the largest number of hops in the previous searching rounds.
The largest network:  10000 nodes
