#include once "vecops13.bas"
#include once "xfile.bas"
' sparse vector weight block - vector to vector associative memory
type amblock
	veclen as ulongint
	density as ulongint
	blockbits as ulongint
	rate as single
	hash as ulongint
	weights(any) as single
	surface(any) as single 
	indexes(any) as ulong
	workA(any) as single
	workB(any) as single
    declare sub init(veclen as ulongint,density as ulongint,blockbits as ulongint,rate as single, hash as ulongint)
    declare sub train(targetVec as single ptr,invec as single ptr)
    declare sub recall(resultvec as single ptr,invec as single ptr,incsur as boolean=false)
    declare sub clearamblock()
    declare sub sizememory()
    declare sub load(wts as boolean)
    declare sub save(wts as boolean)
end type

sub amblock.init(veclen as ulongint,density as ulongint,blockbits as ulongint,rate as single,hash as ulongint)
	this.veclen=veclen
	this.density=density
	this.blockbits=blockbits
	this.rate=rate
	this.hash=hash
	sizememory()
end sub

sub amblock.sizememory()
    redim weights((1 shl blockbits)*density*veclen-1)
    redim surface(density*veclen-1)
    redim indexes(density-1)
	redim workA(vecLen-1)
	redim workB(vecLen-1)
end sub

sub amblock.recall(resultvec as single ptr,invec as single ptr,incsur as boolean=false)
    dim as single ptr wts=@weights(0),wa=@workA(0),sur=@surface(0)
    dim as ulongint skip=veclen*(1 shl blockbits)
	adjust(wa,invec,1!,veclen)
	zero(resultvec,veclen)
	for i as ulongint=0 to density-1
	  hashflip(wa,wa,hash+i,veclen)
	  whtq(wa,veclen)
	  dim as ulong idx=extractindex(wa,blockbits)
	  indexes(i)=idx 'indexing also provides nonlinarity however you could include additional nonlinarity
	  multiplyaddto(resultvec,wa,wts+veclen*idx,veclen) ' for example signof(wa,wa,veclen) beforehand
	  wts+=skip
	  if incsur then
		copy(sur,wa,veclen)
		sur+=veclen
      end if		
	next
	whtq(resultvec,veclen)
	hashflip(resultvec,resultvec,-hash,veclen)
end sub

sub amblock.train(targetVec as single ptr,invec as single ptr)
    dim as single ptr wts=@weights(0),sur=@surface(0),wb=@workB(0)
    dim as ulongint skip=veclen*(1 shl blockbits)
	recall(wb,invec,true)
	subtract(wb,targetVec,wb,veclen)
	hashflip(wb,wb,-hash,veclen)
	whtq(wb,veclen)
	scale(wb,wb,rate/density,veclen)
	for i as ulongint=0 to density-1
	   multiplyaddto(wts+veclen*indexes(i),sur,wb,veclen)
	   wts+=skip
	   sur+=veclen
	next
end sub

sub amblock.clearamblock()
  dim as single ptr wts=@weights(0)
  zero(wts,ubound(weights)+1)
end sub
  
'save using xfile
sub amblock.save(savewts as boolean)
	xfile.save(veclen)
	xfile.save(density)
	xfile.save(blockbits)
	xfile.save(rate)
	xfile.save(hash)
	if savewts then xfile.save(weights())
end sub

sub amblock.load(loadwts as boolean)
	xfile.load(veclen)
	xfile.load(density)
	xfile.load(blockbits)
	xfile.load(rate)
	xfile.load(hash)
	sizememory()
    if loadwts then xfile.load(weights())
end sub
