argv = System.argv()
unless length(argv) == 2 do
  IO.puts "Input: mix run project3.exs numNodes numRequests" 
else
  numNodes  =  Enum.at(argv,0) |> String.to_integer()
  numRequests  =  Enum.at(argv,1) |> String.to_integer()
  {numNodes,numRequests}
  #IO.puts "numnodes #{numNodes}"
  #IO.puts "numrequests #{numRequests}"
  IO.puts "Start build nodes and neighbor map..."
  nodelist = []
  nodelist = Tapestry.BuildNode.build_topology(numNodes, nodelist)
  IO.puts "Finish: building nodes."
  IO.puts "Start #{numRequests} requests for each nodes..."
  Tapestry.RountingStart.start_rounting(numNodes, nodelist, numRequests)
end


