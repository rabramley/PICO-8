pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main
function _init()
  init_player()
end

function _update()
  dbg={}
  update_player()
end

function _draw()
  cls()
  map()
  draw_player()
  draw_score()
  draw_debug()
end

function draw_score()
  rect(0,119,127,127,8)
  print("lives: ",5,121,8)
end
-->8
-- tools

function cycle(arr,i,hz)
  hz=max(0,hz)  
  return arr[(flr((i*hz)%#arr)+1)]
end

function debug(msg)
  add(dbg,msg)
end

function draw_debug()
  for i=1,#dbg do
    print(dbg[i],80,(i-1)*7,7)
  end 
end

-->8
-- player

function _init()
		pl_sprs={1,2,3,2}
  pl={
    x=0,
    y=0,
    last_x=0,
    last_y=0,
    mv_buff={},
    sp=1,
    last_sp=1,
    fl_x=false,
    fl_y=false,
  }
end

function update_player()
  get_pl_move()

  if pl_anim and costatus(pl_anim) != 'dead' then
    coresume(pl_anim)
  else
    pl_anim = nil
    if #pl.mv_buff>0 then
	     pl_anim=move_pl()
      coresume(pl_anim)
    end
  end
end

function get_pl_move()
  local mv={dx=0,dy=0}
  
  if btnp(⬅️) then
    mv.dx=-1
  elseif btnp(➡️) then
    mv.dx=1
  elseif btnp(⬇️) then
    mv.dy=1
  elseif btnp(⬆️) then
    mv.dy=-1
  else
    mv=nil
  end
  
  if mv then
    add(pl.mv_buff,mv)
  end
end

function move_pl()
  local mv=pl.mv_buff[1]
  local dx,dy=mv.dx*grid_size,mv.dy*grid_size

  local nx=pl.x+dx
  local ny=pl.y+dy
  local result
  
  pl.last_x=pl.x
  pl.last_y=pl.y

  if dy>0 and mfget(nx,ny,flag_n)
    or dy<0 and mfget(nx,ny,flag_s)
    or dx>0 and mfget(nx,ny,flag_w)
    or dx<0 and mfget(nx,ny,flag_e) then
    pl.x,pl.y=nx,ny
    result=cocreate(pl_anim_walk)
  else
    if mfget(nx,ny,flag_break) then
      break_tile(nx,ny) 
    end
    
    pl.mv_buff={}
    result=cocreate(pl_anim_bounce)
  end

  deli(pl.mv_buff,1)

  pl.fl_y=(mv.dy>0)
  pl.fl_x=(mv.dx<0)
  pl.axis=mv.dy!=0

  return result
end

function pl_anim_walk()
  sfx(0)
 
  pl.sp=7
  pl.last_sp=1
  yield()
   
		for fr=6,1,-1 do
    if pl.axis then      
      pl.last_sp=fr+7
      pl.sp=14-fr
    else
      pl.last_sp=8-fr
      pl.sp=fr+1
    end
    yield()
		end

  pl.sp=1
  pl.last_sp=7
end

function pl_anim_bounce()
  sfx(0)
 
  pl.sp=1
  pl.last_sp=7
  yield()

  local frances
  
  if pl.axis then
    frances={29,28,27,28,29}
  else
    frances={18,19,20,19,18}
  end
     
		for fr in all(frances) do
		  pl.sp=fr
    yield()
		end

  pl.sp=1
end

function draw_player()
  spr(pl.last_sp,pl.last_x,pl.last_y,1,1,pl.fl_x,not pl.fl_y)
  spr(pl.sp,pl.x,pl.y,1,1,not pl.fl_x,pl.fl_y)
end

-->8
-- map
grid_size=8

flag_n=0
flag_e=1
flag_s=2
flag_w=3
flag_break=4

breakfx={}
breakfx["96"]=4
breakfx["112"]=2
breakfx["114"]=3

function break_tile(x,y)
  x,y=pix2tile(x,y)
  s=mget(x,y)
  mset(x,y,s+1)
  
  sfx(breakfx[tostr(s)])
end

function mfget(x,y,f)
  return fget(mget(pix2tile(x,y)),f)
end

function pix2tile(x,y)
  return flr(x/grid_size),flr(y/grid_size)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000bb000000b3000000300000000000000000000000000000000000000000000000000000000000000033000000bb000000bb0000000000000000000
0007700000bbbb0000bbb33300b3333300333333000033330000003300000000000000000000000000000000000330000033330000bbbb000000000000000000
0007700000bbbb0000bbb33300b33333003333330000333300000033000000000000000000000000000330000003300000033000003bb3000000000000000000
00700700000bb000000b300000030000000000000000000000000000000000000000000000000000000330000003300000033000000330000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000033000000330000003300000033000000330000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000033000000330000003300000033000000330000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000030000000b0000000000000000000000000000000000000000000000000000000bbbbbb003bbbb30003bb3000000000000000000
00000000000000000303b0000b0030000bb0000000000000000000000000000000000000000000000000000000bbbb00000bb000000330000000000000000000
00000000000000000b3bbb000bb33b000bb333000000000000000000000000000000000000000000000000000003300000033000003bb3000000000000000000
00000000000000000b3bbb000bb33b000bb33300000000000000000000000000000000000000000000000000000330000033330000bbbb000000000000000000
00000000000000000303b0000b0030000bb0000000000000000000000000000000000000000000000000000000033000000bb000000bb0000000000000000000
000000000000000000000000030000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888888888888888888888800000088888888888888888888888888888888880000008000000000000000000000000000000000000000000000000
00000000888888888800000000000000000000000000008888000000000000880000000000000008000000000000000000000000000000000000000000000000
00700700888888888000000000000000000000000000000880000000000000080000000000000008000000000000000000000000000000000000000000000000
00070000888888888000000000000000000000000000000880000000000000080000000000000008000000000000000000000000000000000000000000000000
00007000888888888000000000000000000000000000000880000000000000080000000000000008000000000000000000000000000000000000000000000000
00700700888888888000000000000000000000000000000880000000000000080000000000000008000000000000000000000000000000000000000000000000
00000000888888888800000000000000000000000000008880000000000000080000000000000008000000000000000000000000000000000000000000000000
00000000888888888888888888888888800000088888888880000008800000088000000880000008000000000000000000000000000000000000000000000000
00000000000000000000000088888888800000088000000880000008800000088000000880000008000000000000000000000000000000000000000000000000
00000000000000000000000088000088800000088000000880000000000000088000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000080000008800000088000000880000000000000088000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000080000008800000088000000880000000000000088000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000080000008800000088000000880000000000000088000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000080000008800000088000000880000000000000088000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000080000008880000888000000888000000000000888000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000080000008888888888000000888888888888888888000000888888888000000000000000000000000000000000000000000000000
88888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80808008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80808008000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000008080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa00006666000aaaaaa00dddddd00aa000000660000003330000066600000000000000000000000000000000000000000000000000000000000000000000
0aa77aa006000060aaa76aaaddd76dddaa7a0000607600003b730000607600000000000000000000000000000000000000000000000000000000000000000000
aaaaa7aa60077006aaa76aaaddd76dddaaaa0000600600003bb30000600600000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa60000706a777777ad777777d0aa000000660000033300000666000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa60000006a667666ad667666d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa60000006aaa76aaaddd76ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa0060000600aa76aaa0dd76ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa00006666000aaaaaa00dddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888ffffff882222228888888888888888888888888888888888888888888888888888888888888888228228888ff88ff888222822888888822888888228888
88888f8888f882888828888888888888888888888888888888888888888888888888888888888888882288822888ffffff888222822888882282888888222888
88888ffffff882888828888888888888888888888888888888888888888888888888888888888888882288822888f8ff8f888222888888228882888888288888
88888888888882888828888888888888888888888888888888888888888888888888888888888888882288822888ffffff888888222888228882888822288888
88888f8f8f88828888288888888888888888888888888888888888888888888888888888888888888822888228888ffff8888228222888882282888222288888
888888f8f8f8822222288888888888888888888888888888888888888888888888888888888888888882282288888f88f8888228222888888822888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557777777777770000000000000000000000000000005555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557777777777775555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000022222222222222222222222222222222000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000022222222222222222222222222222222000000000000000005555550444444444455555555556666666666777777777705555555
5555555000000000000000002222222222222222222222222222222200000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000002222222222222222222222222222222200000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000002222222222222222222222222222222200000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000002222222222222222222222222222222200000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000002222222222222222222222222222222200000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000002222222222222222222222222222222200000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000222222222222222222222222dddddddd2222222222222222000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000222222222222222222222222dddddddd2222222222222222000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000222222222222222222222222dddddddd2222222222222222000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000222222222222222222222222dddddddd22222222222222220000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
5555555000000000222222222222222222222222dddddddd22222222222222220000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
5555555000000000222222222222222222222222dddddddd22222222222222220000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
5555555000000000222222222222222222222222dddddddd22222222222222220000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
5555555000000000222222222222222222222222dddddddd22222222222222220000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000002222222222222222222222222222222222222222000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000002222222222222222222222222222222222222222000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000002222222222222222222222222222222222222222000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000002222222222222222222222222222222222222222000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000002222222222222222222222222222222222222222000000000000000005555550000000000000000000000000000000000000000005555555
55555550000000002222222222222222222222222222222222222222000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000002222222222222222222222222222222222222222000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000002222222222222222222222222222222222222222000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000022222222222222222222222222222222222222220000000005555556666666555556667655555555555555555555555555555555
55555550000000000000000022222222222222222222222222222222222222220000000005555556666666555555666555555555555555555555555555555555
5555555000000000000000002222222222222222222222222222222222222222000000000555555666666655555556dddddddddddddddddddddddd5555555555
555555500000000000000000222222222222222222222222222222222222222200000000055555566606665555555655555555555555555555555d5555555555
55555550000000000000000022222222222222222222222222222222222222220000000005555556666666555555576666666d6666666d666666655555555555
55555550000000000000000022222222222222222222222222222222222222220000000005555556666666555555555555555555555555555555555555555555
55555550000000000000000022222222222222222222222222222222222222220000000005555556666666555555555555555555555555555555555555555555
55555550000000000000000022222222222222222222222222222222222222220000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000022222222222222222222222222222222222222222222222205555555555555555555555555555555555555555555555555555555
55555550000000000000000022222222222222222222222222222222222222222222222205555556665666555556667655555555555555555555555555555555
55555550000000000000000022222222222222222222222222222222222222222222222205555556555556555555666555555555555555555555555555555555
5555555000000000000000002222222222222222222222222222222222222222222222220555555555555555555556dddddddddddddddddddddddd5555555555
555555500000000000000000222222222222222222222222222222222222222222222222055555565555565555555655555555555555555555555d5555555555
55555550000000000000000022222222222222222222222222222222222222222222222205555556665666555555576666666d6666666d666666655555555555
55555550000000000000000022222222222222222222222222222222222222222222222205555555555555555555555555555555555555555555555555555555
55555550000000000000000022222222222222222222222222222222222222222222222205555555555555555555555555555555555555555555555555555555
55555550000000002222222222222222222222222222222222222222222222220000000005555555555555555555555555555555555555555555555555555555
55555550000000002222222222222222222222222222222222222222222222220000000005555555555555555555555555555555555555555555555555555555
55555550000000002222222222222222222222222222222222222222222222220000000005555550005550005550005550005550005550005550005550005555
555555500000000022222222222222222222222222222222222222222222222200000000055555011d05011d05011d05011d05011d05011d05011d05011d0555
55555550000000002222222222222222222222222222222222222222222222220000000005555501110501110501110501110501110501110501110501110555
55555550000000002222222222222222222222222222222222222222222222220000000005555501110501110501110501110501110501110501110501110555
55555550000000002222222222222222222222222222222222222222222222220000000005555550005550005550005550005550005550005550005550005555
55555550000000002222222222222222222222222222222222222222222222220000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555575555555ddd55555d5d5d5d55555d5d555555555d5555555ddd5555550000000055555555555555555555555555555555555555555555555555
555555555555777555555ddd55555555555555555d5d5d55555555d55555d555d555550000000056666666666666555557777755555555555555555555555555
555555555557777755555ddd55555d55555d55555d5d5d555555555d555d55555d55550022220056ddd6ddd6dd66555577ddd775566666555666665556666655
555555555577777555555ddd55555555555555555ddddd5555ddddddd55d55555d55550222d22056d6d6d6d66d66555577d7d77566dd666566ddd66566ddd665
5555555557577755555ddddddd555d55555d555d5ddddd555d5ddddd555d55555d55550222220056d6d6d6d66d66555577d7d775666d66656666d665666dd665
5555555557557555555d55555d55555555555555dddddd555d55ddd55555d555d555550022222056d6d6d6d66d66555577ddd775666d666566d666656666d665
5555555557775555555ddddddd555d5d5d5d555555ddd5555d555d5555555ddd5555550022222256ddd6ddd6ddd655557777777566ddd66566ddd66566ddd665
55555555555555555555555555555555555555555555555555555555555555555555550222222056666666666666555577777775666666656666666566666665
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555566666665ddddddd5ddddddd5ddddddd5
00000007777777777000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007000000007000000000000000000000000000171000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007000000007022220000000000000000000000177100000000000000000000000000000000000000000000000000000000000000000000000000000000
00700707002222007022d22000222200000000000000177710000000000000000000000000000000000000000000000000000000000000000000000000000000
000770070222d220702222200222d220000000000000177771000000000000000000000000000000000000000000000000000000000000000000000000000000
00077007022222007022220002222220000000000000177110000000000000000000000000000000000000000000000000000000000000000000000000000000
00700707002222207022220022222200000000000000011710000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007002222227022222022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007022222207022222202222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020a0f08060c0e0d0000000000000000000401050309070b0000000000000201000000000000000000000000000002010201020102010000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4643474141414141414141414141414142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5845555341414141414141414141414142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5848575649414141414141414141414142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5556484357414141414141414141414142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5546444141414141414141414141414142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5657554141414141414141414141414142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4643594141414141414141414141414142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5647414141414141414141414141414142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4259414141414141414141414141414142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4241604142414141424160414141420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424142414141424142414141420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4241414142424242424142704143420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424141414141414142424242420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000085200a520016200372005720016200160000000000000000000000000000000000000000000050007510085100261005710057100061000000000000000000000000000000000000000000000000000
000100001d1201d1301d1501c1501b150191501715015150121500c150071500115000150000000b1000d1000d1000d1000000000000000000000000000221002310025100251002610027100000000000000000
4a0c0000082110a2110c2111f2112221127211292110920109201092010a2010b2010c2010d2010e2010f2010f2010f2011020112201122011320113201142011520116201192011b2011d201212010020100201
0701000037b4237b4237b4200b0200b0200b0200b0237b3235b3234b3234b3200b0200b0200b0200b0200b0228b2225b2224b2200b0200b0200b0225b1221b121eb121bb1218b1217b1202b0200b0200b0200b02
000200000014001120016200362003620066300563002030030200163003640046300762005620050200502003020016200162003120061200211000110001100111002100021000110001100001000010000100
