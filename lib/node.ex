defmodule Tapestry.Node do 
  use GenServer
  
  ##################### client side ########################
  # initial values 
  # 0:rumor, 1:times heard the rumor, 2:s, 3:w, 4:neighbors tuple, 
  # 5:node's mazai process id, mazai is a process spawned from this node and used for keep sending rumors
  # 6:the number of this node(Genserver)
  def start_link(nodename,nodeid) do 
    #nodeid = Base.encode16(:crypto.hash(:sha, Integer.to_string(nodenum)))
    #IO.puts "#{inspect nodename} #{nodeid}"
    GenServer.start_link(__MODULE__,["",0,nodeid,1,[],0,nodename], name: nodename)
    #IO.puts "start_link finished"
  end

  # update neighbor list of a node
  def update_neighbor(nodename,neighbormap) do
    GenServer.cast(nodename, {:update_neighbor,neighbormap})
  end

  def newnode_coming(nodename,newnodename,newnodeid) do
    "node"<>x = Atom.to_string(nodename)
    curid = Base.encode16(:crypto.hash(:sha, x))
    p = lcp([curid, newnodeid])
    #IO.puts "p #{p}"
    GenServer.cast(nodename, {:newnode_coming,newnodename,newnodeid,p})
    GenServer.cast(newnodename,{:find_p,nodename,curid,p})
  end

  def route_to_node(startnode, nodename, destination, hop, p) do
    d_id = GenServer.call(destination, :get_id)
    curid = GenServer.call(nodename, :get_id)
    p = lcp([d_id, curid])
    {j,""} = Integer.parse(String.at(d_id, p), 16)
    neighbormap = get_neighbors(nodename)
    nextnode = Enum.at(neighbormap, p) |> Enum.at(j)
    #IO.puts "startnode #{startnode}  nextnode #{inspect nextnode}  hop #{hop}"
    hop = hop + 1
    cond do
      nextnode == 0 -> IO.puts "startnode #{startnode}  nodename #{inspect nodename}  destination #{inspect destination}  curhop #{hop}"
      nextnode == destination -> hop
      true -> route_to_node(startnode, nextnode, destination, hop, p)
    end

  end

  def get_neighbors(nodename) do
    GenServer.call(nodename, :get_neighbors)
  end

  def get_id(nodename) do
    GenServer.call(nodename, :get_id)
  end

"""
  def get_metadata(nodename) do 
      GenServer.call(nodename, :get_metadata)
  end
  # send rumor to this nodename node
  def send_rumor(nodename, rumor, mainpid) do
      GenServer.cast(nodename, {:send_rumor,rumor,mainpid})
  end

  def do_pushsum(nodename, s, w, mainpid) do
      GenServer.cast(nodename, {:do_pushsum, s, w, mainpid})
  end
"""
  ################### server side ##########################
  def init(metadata) do 
    {:ok, metadata}
  end

  def handle_call(:get_metadata, _from, metadata) do
    {:reply,metadata,metadata}
  end

  def handle_call(:get_neighbors, _from, metadata) do
    neighbors = Enum.at(metadata,4)
    #IO.puts "#{inspect neighbors}"
    {:reply,neighbors,metadata}
  end
  
  def handle_call(:get_id, _from, metadata) do
    id = Enum.at(metadata,2)
    {:reply,id,metadata}
  end

  def handle_cast({:newnode_coming,newnodename,newnodeid,p}, metadata) do
    #IO.puts "cast:newnode_coming"
    neighbormap = Enum.at(metadata,4)
    currow = Enum.at(neighbormap, p)
    {j,""} = Integer.parse(String.at(newnodeid,p), 16)
    #IO.puts "p #{p}   j #{j}"
    currow = if Enum.at(currow,j) == 0 do
      List.replace_at(currow,j,newnodename)
      else
        currow
      end
    neighbormap = List.replace_at(neighbormap,p,currow)
    #IO.puts "#{inspect currow}"
    #IO.puts "#{inspect Enum.at(metadata,6)} #{inspect neighbormap}"
    {:noreply, List.replace_at(metadata,4,neighbormap)}  
  end

  def handle_cast({:find_p,nodename,curid,p}, metadata) do
    #IO.puts "cast:find_p"
    neighbormap = Enum.at(metadata,4)
    currow = Enum.at(neighbormap, p)
    {j,""} = Integer.parse(String.at(curid,p), 16)
    #IO.puts "p #{p}   j #{j}"
    currow = if Enum.at(currow,j) == 0 do
      List.replace_at(currow,j,nodename)
      else
        currow
      end
    neighbormap = List.replace_at(neighbormap,p,currow)
    #IO.puts "#{inspect currow}"
    #IO.puts "#{inspect Enum.at(metadata,6)}  #{inspect neighbormap}"
    {:noreply, List.replace_at(metadata,4,neighbormap)}  
  end

  def handle_cast({:update_neighbor,neighbormap}, metadata) do
    {:noreply, List.replace_at(metadata,4,neighbormap)}  
  end
   

#longest common prefix
  def lcp([]), do: ""
  def lcp(strs) do
    min = Enum.min(strs)
    max = Enum.max(strs)
    index = Enum.find_index(0..String.length(min), fn i -> String.at(min,i) != String.at(max,i) end)
    #if index, do: String.slice(min, 0, index), else: min
    index
  end


  '''
  def keep_sending_rumor(rumor,neighborlist, mainpid) do      
      idx = neighborlist |> length() |> :rand.uniform()
      rumor_to = Enum.at(neighborlist,idx-1) # name of node who will receive the rumor
      #IO.puts "rumor_to #inspect rumor_to}"
      send_rumor(rumor_to,rumor,mainpid)
      keep_sending_rumor(rumor,neighborlist,mainpid)
  end

  def choose_a_neighbor(neighborlist) do
      idx = neighborlist |> length() |> :rand.uniform()
      Enum.at(neighborlist,idx-1)
  end
  '''

end