#include  "SDL\SDL.bi"
#include  "SDL\SDL_image.bi"

function loadimages(foldername as string,vector() as single,side as ulong) as ulong
dim as ulong count
dim as string imgfile=dir(foldername+"/*.jpg")
while imgfile<>""
  dim as SDL_Surface ptr img=IMG_Load(foldername+"/"+imgfile)
  if img<>0 then 
	  dim as ulong w=img->w,h=img->h,pitch=img->pitch,idxvector,idxImg,x,y,ox,oy,i,j,idx
	  dim as ubyte ptr pixels=img->pixels
	  idxvector=4*side*side*count
	  count+=1
	  redim preserve vector(4*side*side*count-1)
	  dim as single d=csng(w)/side,r,g,b
		if h>w then oy=(h-w) shr 1
		if h<w then
			ox=(w-h) shr 1
			d=csng(h)/side
		end if
		for i=0 to side-1
			for j=0 to side-1
			    x=ox+d*i
			    y=oy+d*j
			    r=(pixels[3*x+pitch*y]-127.5!)*(1!/128!)
			    g=(pixels[3*x+pitch*y+1]-127.5!)*(1!/128!)
			    b=(pixels[3*x+pitch*y+2]-127.5!)*(1!/128!)
			    vector(idxvector)=r:idxvector+=1
			    vector(idxvector)=g:idxvector+=1
			    vector(idxvector)=b:idxvector+=1
			    vector(idxvector)=(r+g+b)*0.3333333333:idxvector+=1
			next
		next
	  SDL_FreeSurface(img)
  end if
  imgfile=Dir()
wend
return count
end function

sub presentimage(x as ulong,y as ulong,array as single ptr,side as ulong)
dim as ulong idx
for j as ulong=0 to side-1
for i as ulong=0 to side-1
	dim as single r=array[idx]:idx+=1
	dim as single g=array[idx]:idx+=1
	dim as single b=array[idx]:idx+=2
	r=r*128!+127.5!
	g=g*128!+127.5!
	b=b*128!+127.5!
	if(r>255!) then r=255!
	if(g>255!) then g=255!
	if(b>255!) then b=255!
	if(r<0!) then r=0!
	if(g<0!) then g=0!
	if(b<0!) then b=0!
	pset (j+x,i+y),RGB(r,g,b)
next
next
end sub
/'
screenres 800,700,32
redim vec() as single
dim as ulong ct=loadimages("photos",vec(),256)
for i as ulong=0 to ct-1
presentimage(0,0,@vec(65536*4*i),256)
getkey
next
'/
