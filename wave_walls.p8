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
gs=8
-- map creation
dirs={
  {dx=-1,dy=0},
  {dx=1,dy=0},
  {dx=0,dy=-1},
  {dx=0,dy=1},
}

-- map creation
function create_map()
  h_edges=init_array(16,16,-1)
  v_edges=init_array(16,16,-1)

  while true do
		  local cands=get_cands()
		  
		  if (#cands==0) return
		  log("iteration: "..tostr(i).."; no of cands: "..tostr(#cands))
		  collapse(rnd(cands))
		end
end

function get_cands()
  local result={}
  local max=-99
  
  for x=0,15 do
    for y=0,15 do
      e=get_entropy(x,y)
      if e>max and e<4 then
        result={{x=x,y=y}}
        max=e
      elseif e==max then
        add(result,{x=x,y=y})
      end
    end
  end
  
  return result
end

function get_entropy(x,y)
  local result=0

		if h_edges[x][y]>=0 then
		  result+=1
		end
		if h_edges[x][y+1]>=0 then
		  result+=1
		end
		if v_edges[x][y]>=0 then
		  result+=1
		end
		if v_edges[x+1][y]>=0 then
		  result+=1
		end

		return result
end


function collapse(pos)
  local x,y=pos.x,pos.y
  local opts={0,0,0,1}

		if h_edges[x][y]<0 then
		  h_edges[x][y]=rnd(opts)
		end
		if h_edges[x][y+1]<0 then
		  h_edges[x][y+1]=rnd(opts)
		end
		if v_edges[x][y]<0 then
		  v_edges[x][y]=rnd(opts)
		end
		if v_edges[x+1][y]<0 then
		  v_edges[x+1][y]=rnd(opts)
		end
end
-->8
-- map draw
function draw_map()
  if map_drawn then
    memcpy(0x6000,0x8000,8192)
  else
    draw_tiles()
    map_drawn=true
  end
end

function draw_tiles()
  for a=0,15 do
    ap=a*gs
    app=ap+gs
		  for b=0,15 do
		    bp=b*gs
		    bpp=bp+gs-1
		    if h_edges[a][b]==1 then
  		    line(ap,bp,app,bp)
  		  end
		    if v_edges[a][b]==1 then
  		    line(ap,bp,ap,bpp)
  		  end
		  end
  end
  flip()
  memcpy(0x8000,0x6000,8192)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
