namespace xfile
	
	dim as long file
	dim as boolean fileerror	'true on error
	
	sub openfile(filename as string)
		file=freefile()
		open filename for binary as #file
		fileerror=iif(err>0,true,false)
	end sub
	
	sub save overload(x as ulongint)
		put #file,,x
	    if err>0 then fileerror=true
	end sub
	
	sub save overload(x as single)
		put #file,,x
	    if err>0 then fileerror=true
	end sub
	
	sub save overload(x() as single)
		put #file,,x()
	    if err>0 then fileerror=true
	end sub
	
	sub save overload(x() as ubyte)
		put #file,,x()
	    if err>0 then fileerror=true
	end sub
	
	sub load overload(byref x as ulongint)
		get #file,,x
		if err>0 then fileerror=true
	end sub
	
	sub load overload(byref x as single)
		get #file,,x
		if err>0 then fileerror=true
	end sub
	
	sub load overload(x() as single)
		get #file,,x()
		if err>0 then fileerror=true
	end sub
	
	sub load overload(x() as ubyte)
		get #file,,x()
		if err>0 then fileerror=true
	end sub
	
	sub closefile()
		close #file
	end sub
end namespace

/'

dim as ulongint a=99,b
dim as single x(99),y(99)
for i as ulong =0 to ubound(x)
	x(i)=i+3
next
xfile.openfile("a.txt")
xfile.save(a)
xfile.save(@x(0),100)
xfile.closefile()
print xfile.fileerror
xfile.openfile("a.txt")
xfile.load(b)
xfile.load(@y(0),100)
xfile.closefile()
print b
print
for i as ulong =0 to ubound(y)
	print y(i)
next
print xfile.fileerror


getkey
'/
