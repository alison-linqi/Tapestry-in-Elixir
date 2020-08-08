defmodule Tapestry.RountingStart do
    
    def start_rounting(nodenum, nodelist, numrequests) do
        #IO.puts "start request"
        start_request(nodenum, nodelist, numrequests, 0)
        #IO.puts "Gossip finished. Maxhop is: #{maxhop}"
    end

    def start_request(nodenum, nodelist, numrequests, maxhop) when numrequests > 0 do
        IO.puts "remain #{numrequests} requests."
        deslist = Enum.map(nodelist, fn x -> Enum.random(nodelist--[x]) end)
        hoplist = Enum.map(nodelist, fn x -> Tapestry.Node.route_to_node(x, x, Enum.at(deslist,Enum.find_index(nodelist,fn y -> y == x end)), 0, 0) end)
        maxhop = if Enum.max(hoplist) > maxhop do
            Enum.max(hoplist)
        else
            maxhop
        end
        Process.sleep 1000
        start_request(nodenum, nodelist, numrequests-1, maxhop)
    end
    def start_request(nodenum, nodelist, numrequests, maxhop) when numrequests == 0 do
        IO.puts "Requests finished. Maxhop is: #{maxhop}"
    end
end