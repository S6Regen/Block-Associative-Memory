#include "amblock.bas"
#include "image.bas"
#include "file.bi"

#define IMGFolder "photos"
#define VALRatio .75
#define NETFile "testamblock.dat"

#define IMGSize 256
#define NETDensity 10
#define NETBlockBits 4
#define NETRate 0.3!
#define NETHash 123456

screenres 400,400,32
dim as boolean training,recall
dim as ulong size=4*IMGSize*IMGSize,counttrain,countrecall,iter,rcount
dim as single images(),work(size)
dim as amblock net

if fileExists(NETFile) then
    print "Loading Network..."
	xfile.openfile(NETFile)
	net.load(true)
	xfile.closefile()
else
    print "Creating Network..."
    net.init(size,NETDensity,NETBlockBits,NETRate,NETHash)
end if
print "Loading training images..."
countrecall=loadimages(IMGFolder,images(),IMGSize)
counttrain=VALRatio*countrecall
do
  var k=inkey()
  if cbool((k="t") or (k="T")) and not recall then
    if training then
      xfile.openfile(NETFile)
      net.save(true)
      xfile.closefile()
    end if 
    training=not training
  end if
  if cbool((k="r") or (k="R")) and not training then recall=not recall
  if k=chr(27) then exit do
  if (not training) and (not recall) then
   cls
   print "T to Train, R to Recall"
   sleep 300
  end if
  if training then
	cls
	print "Training",iter
	for i as ulong=0 to counttrain-1
		net.train(@images(i*size),@images(i*size))
	next
	iter+=1
  end if
  if recall then
    cls
    print "Recall",rcount,iif(rcount<counttrain,"T set","Val set")
    net.recall(@work(0),@images(rcount*size))
	presentimage(100,100,@work(0),IMGSize)
	rcount+=1
	if rcount=countrecall then rcount=0
	sleep 2000
  end if
loop

