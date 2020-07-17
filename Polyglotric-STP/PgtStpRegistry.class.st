Class {
	#name : #PgtStpRegistry,
	#superclass : #Object,
	#instVars : [
		'registry',
		'path',
		'headers'
	],
	#category : #'Polyglotric-STP'
}

{ #category : #private }
PgtStpRegistry class >> loadFrom: aPath [

	| inst |
	inst := self new path: aPath; yourself.
	inst load.
	^ inst
]

{ #category : #public }
PgtStpRegistry >> convertToCSV: aPath [

	| msgHeaders |
	msgHeaders := headers copyFrom: 3 to: headers size.
	
	aPath asFileReference 
		writeStreamDo:[:stream |
			
			stream nextPutAll: (String streamContents: [:s | headers do: [:each | s << each asString] separatedBy: [s << ',']]);cr.
			
			registry
				doWithIndex: [ :eaRecord :idx|
					| msg | 
					
					msg := eaRecord at: 'message'.
					
					stream 
						nextPutAll: ((eaRecord at: 'id') ifNil:['not present']); 
						nextPut: $,;
						nextPutAll: idx asString;
						nextPut: $,.
						
					stream nextPutAll: (String streamContents: [:s | msgHeaders do: [:eaMsgHdr | s << (msg at: eaMsgHdr ifAbsent: ['nil'])] separatedBy: [s << ',']]);cr.		
			  ]	.
		
	]
]

{ #category : #private }
PgtStpRegistry >> extractHeaders [
	| set operandBlock |
	
	headers := OrderedCollection new.
	
	headers
		add: 'id';
		add: 'pos'.
		
	operandBlock := [ :v | v asInteger ifNil: [ Float infinity ] ].
	
	set := Set new.
	
	registry do: [ :ea | set addAll: (ea at: 'message') keys ].
	headers addAll: (set asSortedCollection: [ :a :b | (operandBlock value: a) <= (operandBlock value: b) ])
]

{ #category : #private }
PgtStpRegistry >> load [
	""

	| string stream dictColl |
	"extract headers"
	string := (stream := path readStream) contents.
	dictColl := OrderedCollection new.
	string linesDo: [ :eaLn | 
		dictColl add: (NeoJSONReader fromString: eaLn) ].
	stream close.
	registry := dictColl.
	self extractHeaders
]

{ #category : #accessing }
PgtStpRegistry >> path [
	^ path
]

{ #category : #accessing }
PgtStpRegistry >> path: anObject [
	path := anObject
]
