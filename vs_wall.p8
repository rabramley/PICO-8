pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
  map_drawn=false
  create_map()
end

function _update()
end

function _draw()
  cls()
  draw_map()
end


-->8
-- tools

function init_array(y,x,val)
  local result={}
  
  for _y=0,y do
    result[_y]={}
    for _x=0,x do
      result[_y][_x]=val
    end
  end
  
  return result
end

function log(m)
  printh(m,"log.txt")  
end
-->8
-- map
n=1
ne=2
e=4
se=8
s=16
sw=32
w=64
nw=128

dirs={
  {dx=-1,dy=0},
  {dx=1,dy=0},
  {dx=0,dy=-1},
  {dx=0,dy=1},
}

ch_room=1
ch_vein=2

function is_a(x,y,val)
  if (x<0 or x>15 or y<0 or y>15) return false
  return chart[y][x]==val
end

function is_vein(x,y)
  return is_a(x,y,ch_vein)
end

function is_room(x,y)
  return is_a(x,y,ch_room)
end

function is_empty(x,y)
  return is_a(x,y,0)
end

function is_clump_forming(x,y)
  for dx=-1,0 do
    for dy=-1,0 do
      local unfilled=0
      if (is_empty(x+dx,y+dy)) unfilled+=1
      if (is_empty(x+dx+1,y+dy)) unfilled+=1
      if (is_empty(x+dx,y+dy+1)) unfilled+=1
      if (is_empty(x+dx+1,y+dy+1)) unfilled+=1

      if unfilled<2 then
        return true
      end
    end
  end
  return false
end

-- map creation
function create_map()
  tiles=init_array(15,15,255)
  chart=init_array(15,15,0)
  add_rooms()
  add_paths()
  add_room_tiles()
end

-- room creation
function add_rooms()
  for i=30,1,-1 do
    local height=2+ceil(rnd(i/4))
    local width=2+ceil(rnd(i/4))
    local x1=min(flr(rnd(15)),15-width)
    local y1=min(flr(rnd(15)),15-height)

    local x2,y2=x1+width,y1+height
    local skip=false

		  for y=y1,y2 do
		    for x=x1,x2 do
		      if (not is_empty(x,y)) skip=true
		    end
		  end

    if not skip then
				  for y=y1,y2 do
				    for x=x1,x2 do
				      chart[y][x]=i
				    end
				  end
				end  
  end
end

function add_room_tiles()
  for y=0,15 do
    for x=0,15 do
      local tt=chart[y][x]
      
      if tt>0 then
		      local v=0
		      
		      if (not is_a(x-1,y,tt)) v=v|w|nw|sw
		      if (not is_a(x+1,y,tt)) v=v|e|ne|se
		      if (not is_a(x,y-1,tt)) v=v|n|ne|nw
		      if (not is_a(x,y+1,tt)) v=v|s|se|sw

		      tiles[y][x]=v
	     end
    end
  end
end

-- vein creator
function add_paths()
	 local path_id=31
	 
	 repeat
			 local cands={}
		  for _y=0,15 do
		    for _x=0,15 do
		      if is_empty(_x,_y) and not is_clump_forming(_x,_y) then
		        add(cands,{y=_y,x=_x})
		      end
		    end
		  end
		  
		  if #cands>0 then
		    dig_vein(rnd(cands),path_id)
		    path_id+=1
		  end
		until #cands<10
end

function dig_vein(pos,path_id)
  while pos do
    chart[pos.y][pos.x]=path_id

    nexts=get_path_next(pos)
    
    if #nexts>0 then
      pos=rnd(nexts)
    else
      pos=nil
    end
  end
end

function get_path_next(pos)
  local result={}
  
  for n in all(dirs) do
    local nx,ny=pos.x+n.dx,pos.y+n.dy
    
    if is_empty(nx,ny) and not is_clump_forming(nx,ny) then
      add(result,{x=nx,y=ny})
    end
  end

  return result  
end

-- map drawing
function draw_map()
  if map_drawn then
    memcpy(0x6000,0x8000,8192)
  else
    draw_tiles()
    map_drawn=true
  end
end

function draw_tiles()
  for y=0,15 do
    for x=0,15 do
      draw_tile(tiles[y][x],x,y)
    end
  end
  flip()
  memcpy(0x8000,0x6000,8192)
end

function draw_tile(tile,x,y)
  local x1,y1=x*8,y*8
  local x2,y2=x1+7,y1+7

  if tile&(n|e|s|w)==(n|e|s|w) then
    rectfill(x1,y1,x2,y2,14)
  else
		  color(7)
		  if tile&n>0 then
		    line(x1+1,y1,x2-1,y1)
		  end
		  if tile&ne>0 then
		    pset(x2,y1)
		  end
		  if tile&e>0 then
		    line(x2,y1+1,x2,y2-1)
		  end
		  if tile&se>0 then
 	    pset(x2,y2)
		  end
		  if tile&s>0 then
		    line(x1+1,y2,x2-1,y2)
		  end
		  if tile&sw>0 then
		    pset(x1,y2)
		  end
		  if tile&w>0 then
		    line(x1,y1+1,x1,y2-1)
		  end
		  if tile&nw>0 then
		    pset(x1,y1)
		  end
		  if tile&(n|e)==(n|e) then
		    pset(x2-1,y1+1,7)
		    pset(x2,y1,14)
		  end
		  if tile&(s|e)==(s|e) then
		    pset(x2-1,y2-1,7)
		    pset(x2,y2,14)
		  end
		  if tile&(s|w)==(s|w) then
		    pset(x1+1,y2-1,7)
		    pset(x1,y2,14)
		  end
		  if tile&(n|w)==(n|w) then
		    pset(x1+1,y1+1,7)
		    pset(x1,y1,14)
		  end
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
