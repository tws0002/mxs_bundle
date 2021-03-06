/***************************************************************************************************
Copyright (C) 2013 - 2017  Gavyn Thompson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. if not, see <http://www.gnu.org/licenses/>.
***************************************************************************************************/
/***************************************************************************************************
Author:				    Gavyn Thompson
Company:				GTVFX
Website:				https://github.com/gtvfx
Email:				    gftvfx@gmail.com
ScriptVersion:			
Updated:				
***************************************************************************************************/
/*
__HELP__

Constructor: 
Instantiated Global: 

[METHODS]


[DESCRIPTION]
Class for dealing with object wirecolor methods

[USAGE]


__END__
*/



mxs.Using "MxsCommonFns"


struct WireColor
(
	savedWireColorArr,
	
	fn RandomWireColor objArr:(GetCurrentSelection()) =
	(
		if objArr.count == 0 then objArr = (objects as array)
		for i in objArr do i.wirecolor = ( random [20,20,20] [230,230,230] )
		True
	),
	
	fn ByLayer =
	(
		LayerManager.CloseDialog()
		for i = 0 to layerManager.count-1 do
		(
			layer = ILayerManager.getLayerObject i
			layer.Nodes &nodeArr
			if nodeArr.count != 0 then
			(
				nodeArr.wireColor = ( random [20,20,20] [230,230,230] )
			)
		)
		True
	),
	
	fn ByMaterial objArr:(GetCurrentSelection()) =
	(
		if objArr.count == 0 then objArr = ( objects as array )
		for i in 1 to sceneMaterials.count do
		(
			randomColor = ( random [20,20,20] [230,230,230] )
			matObjs = for obj in objArr where obj.material == sceneMaterials[i] do ( obj.wireColor = randomColor)
		)
		true
	),
	
	fn CollectObjIdArr objArr =
	(
		objIdArr = #()
		for obj in objArr where ( isProperty obj #gBufferChannel ) do ( appendIfUnique objIdArr obj.gBufferChannel )
		objIdArr
	),
	
	fn ByObjID objArr:(GetCurrentSelection()) =
	(
		if objArr.count == 0 then objArr = ( geometry as array )
		
		local objIdArr = this.CollectObjIdArr objArr
			
		for x = 1 to objIdArr.count do
		(
			local randomColor = ( random [20,20,20] [230,230,230] )
			for obj in objArr where obj.gBufferChannel == objIdArr[x] do ( obj.wireColor = randomColor)
		)
		True
	),
	
	fn CollectFaceIdArr objArr faceIndex:1 =
	(
		local faceIdArr = #()
		
		for obj in objArr do 
		(
			if isProperty obj #mesh then
			(
				appendIfUnique faceIdArr (getFaceMatID obj.mesh 1)
			)
			else
			(
				format "% has no 'mesh' property and is being skipped\n" obj.name
			)
		)
	),
	
	fn ByFaceID objArr:(GetCurrentSelection()) =
	(
		if objArr.count == 0 then objArr = geometry
			
		local faceIdArr = this.CollectFaceIdArr objArr
		
		for x = 1 to faceIdArr.count do
		(
			local randomColor = ( random [20,20,20] [230,230,230] )
			for obj in objArr where ( isProperty obj #mesh ) and ( (getFaceMatID obj 1) == faceIdArr[x] ) do
			(
				( obj.wireColor = randomColor)
			)
		)
		True
	),
	
	fn ByHierarchy objArr:(GetCurrentSelection()) =
	(
		if objArr.count == 0 then objArr = ( objects as array )
		for obj in objArr do
		(
			local childArr = ::MxsCommonFns.GetChildrenRecursive obj 
			if childArr.count != 0 then
			(
				childArr.wireColor = ( random [20,20,20] [230,230,230] )
			)
		)
		True
	),
	
	fn ByInstance objArr arr:#()=
	(
		for i in objArr do
		(
			if findItem arr i == 0 then
			(
				local instanceArr = refs.dependentNodes i.baseObject
				deleteItem instanceArr (findItem instanceArr i)
				if instanceArr.count > 0 then
				(
					i.wirecolor = random [20,20,20] [230,230,230]
					for each in instanceArr do
					(
						appendIfUnique arr each
						each.wireColor = i.wireColor
					)
				)
				else i.wirecolor = (color 128 128 128)
			)
		)
		True
	),
	
	fn SaveWireColor objArr =
	(
		this.savedWireColorArr = #()
		for i in objArr do
		(
			local subArr = #(i.name,i.wirecolor)
			SetUserProp i "GTVFX_WireColor" i.wirecolor
			append this.savedWireColorArr subArr
		)
		format "***** WireColor Stored *****\n"
		this.savedWireColorArr
	),
	
	fn FromSave objArr =
	(
		if this.savedWireColorArr.count != 0 then
		(
			for arr in this.savedWireColorArr do
			(
				iNode = ( GetNodeByName arr[1] )
				if iNode != undefined then
				(
					iNode.wireColor = arr[2]
				)
			)
		)
		else for i in arr do
		(
			if (getUserProp i "GTVFX_WireColor") != undefined then i.wireColor = execute (getUserProp i "GTVFX_WireColor")
		)
		format "***** WireColor Restored *****\n"
	),
	
private
    
    fn __init__ =
	(
        -- pass
	),
	
	_init = __init__()
)

_wireColor = WireColor()