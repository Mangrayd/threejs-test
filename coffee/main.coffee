'use strict';
###Class APP###

### CONSTRUCTOR ###
cApp = () ->
	@cube = new THREE.Object3D()
	@cubeNum = 10000
	@cubeSide = 10
	@cubeCoords = {
		1:{ 1:{x:@cubeSide/2,y:@cubeSide/2,z:-@cubeSide/2}, 2:{x:@cubeSide/2,y:@cubeSide/2,z:@cubeSide/2} },
		2:{ 1:{x:@cubeSide/2,y:@cubeSide/2,z:-@cubeSide/2}, 2:{x:-@cubeSide/2,y:@cubeSide/2,z:-@cubeSide/2} },
		3:{ 1:{x:@cubeSide/2,y:@cubeSide/2,z:-@cubeSide/2}, 2:{x:@cubeSide/2,y:-@cubeSide/2,z:-@cubeSide/2} },

		4:{ 1:{x:-@cubeSide/2,y:-@cubeSide/2,z:-@cubeSide/2}, 2:{x:@cubeSide/2,y:-@cubeSide/2,z:-@cubeSide/2} },
		5:{ 1:{x:-@cubeSide/2,y:-@cubeSide/2,z:-@cubeSide/2}, 2:{x:-@cubeSide/2,y:@cubeSide/2,z:-@cubeSide/2} },
		6:{ 1:{x:-@cubeSide/2,y:-@cubeSide/2,z:-@cubeSide/2}, 2:{x:-@cubeSide/2,y:-@cubeSide/2,z:@cubeSide/2} }

		7:{ 1:{x:-@cubeSide/2,y:@cubeSide/2,z:@cubeSide/2}, 2:{x:@cubeSide/2,y:@cubeSide/2,z:@cubeSide/2} },
		8:{ 1:{x:-@cubeSide/2,y:@cubeSide/2,z:@cubeSide/2}, 2:{x:-@cubeSide/2,y:-@cubeSide/2,z:@cubeSide/2} },
		9:{ 1:{x:-@cubeSide/2,y:@cubeSide/2,z:@cubeSide/2}, 2:{x:-@cubeSide/2,y:@cubeSide/2,z:-@cubeSide/2} }

		10:{ 1:{x:@cubeSide/2,y:-@cubeSide/2,z:@cubeSide/2}, 2:{x:-@cubeSide/2,y:-@cubeSide/2,z:@cubeSide/2} },
		11:{ 1:{x:@cubeSide/2,y:-@cubeSide/2,z:@cubeSide/2}, 2:{x:@cubeSide/2,y:@cubeSide/2,z:@cubeSide/2} },
		12:{ 1:{x:@cubeSide/2,y:-@cubeSide/2,z:@cubeSide/2}, 2:{x:@cubeSide/2,y:-@cubeSide/2,z:-@cubeSide/2} }
	}
	@cubeClone = undefined

	@sphereRadius = 1
	@sphereClone = undefined
	@spheres = []
	@spheresCoords = {
		1: {x:-@cubeSide/2,y:-@cubeSide/2,z:-@cubeSide/2},
		2: {x:+@cubeSide/2,y:+@cubeSide/2,z:+@cubeSide/2},
		3: {x:+@cubeSide/2,y:-@cubeSide/2,z:-@cubeSide/2},
		4: {x:-@cubeSide/2,y:+@cubeSide/2,z:-@cubeSide/2},
		5: {x:-@cubeSide/2,y:-@cubeSide/2,z:+@cubeSide/2},
		6: {x:+@cubeSide/2,y:+@cubeSide/2,z:-@cubeSide/2},
		7: {x:-@cubeSide/2,y:+@cubeSide/2,z:+@cubeSide/2},
		8: {x:+@cubeSide/2,y:-@cubeSide/2,z:+@cubeSide/2}
	}

	@arrSpheres = []
	@arrLines = []

	@scene = undefined
	@camera = undefined
	@renderer = undefined
	@orbit = undefined
	@plane = undefined
	@selectedObject = undefined
	@projector = new THREE.Projector()
	@offset = new THREE.Vector3()

	return

### INITILIZATIONS ###
cApp.prototype.PlaneInit = ()->
	@plane = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 2000, 18, 18 ), new THREE.MeshBasicMaterial() )
	@plane.visible = false
	@scene.add( @plane )
	return
cApp.prototype.CameraInit = () ->
	@camera = new THREE.PerspectiveCamera(30, window.innerWidth / window.innerHeight, 0.1, 1000)
	@camera.position.x = 100
	@camera.position.y = 90
	@camera.position.z = 90
	@camera.lookAt(@scene.position)
	return
cApp.prototype.RenderInit = ()->
	@renderer = new THREE.WebGLRenderer()
	@renderer.setClearColor(new THREE.Color(0xEEEEEE))
	@renderer.setSize(window.innerWidth, window.innerHeight)
	return
cApp.prototype.Rendering = ()->
	@renderer.render(@scene, @camera)
	@cube.position.needsUpdate = true
	@orbit.update()
	requestAnimationFrame(@Rendering.bind(@))
	return

### EVENTS ###
cApp.prototype.MouseDownEvent = (event)->
	mouse_x = ( event.clientX / window.innerWidth ) * 2 - 1
	mouse_y = -( event.clientY / window.innerHeight ) * 2 + 1
	### convert mouse position to 3D ###
	vector = new THREE.Vector3(mouse_x, mouse_y, 0.5)
	vector.unproject(@camera)
	### define the intersects ###
	raycaster = new THREE.Raycaster(@camera.position, vector.sub(@camera.position).normalize())
	intersects = raycaster.intersectObjects(@arrSpheres)

	### if intersects ###
	if intersects.length > 0

		@orbit.enabled = false
		@selectedObject = intersects[0].object
		position = @selectedObject.position

		i = 0
		while i < @arrLines.length
			## find lines in parent of selected obj
			if @arrLines[i].parent.uuid == @selectedObject.parent.uuid
				j = 0
				while j < 2
					if position.x == @arrLines[i].geometry.vertices[j].x && position.y == @arrLines[i].geometry.vertices[j].y && position.z == @arrLines[i].geometry.vertices[j].z
						@arrLines[i].material = @selectedObject.material
					j++
			i++
	return
cApp.prototype.MouseUpEvent = ()->
	@orbit.enabled = true
	@selectedObject = null
	return
cApp.prototype.onWindowResize = ()->
	@camera.aspect = window.innerWidth / window.innerHeight
	@camera.updateProjectionMatrix()
	@renderer.setSize( window.innerWidth, window.innerHeight )
	return

### CREATE OBJECTS ###
cApp.prototype.CreateCube = () ->
	i = 1
	while i <= 12
		@CreateCubeLines(i)
		i++
	##
	j = 1
	while j <= 8
		@CreateCubeSpheres(j)
		j++
	return
cApp.prototype.CreateCubeLines = (i) ->
	lineCoords = @cubeCoords[i]
	lineGeometry = new THREE.Geometry()
	lineMaterial = new THREE.LineBasicMaterial({ color: 0x000000 })
	lineGeometry.vertices.push(
		new THREE.Vector3( lineCoords[1].x, lineCoords[1].y, lineCoords[1].z ),
		new THREE.Vector3( lineCoords[2].x, lineCoords[2].y, lineCoords[2].z )
	)
	line = new THREE.Line( lineGeometry, lineMaterial )
	@cube.add( line )

	return
cApp.prototype.CreateCubeSpheres = (j) ->
	sphereGeometry = new THREE.SphereGeometry( @sphereRadius )
	sphereMaterial = new THREE.MeshBasicMaterial( {color: Math.random() * 0xffffff} )
	sphere = new THREE.Mesh( sphereGeometry, sphereMaterial )

	sphere.position.x = @spheresCoords[j].x
	sphere.position.y = @spheresCoords[j].y
	sphere.position.z = @spheresCoords[j].z

	@cube.add( sphere )
	##@arrSpheres[sphere.parent.uuid][j] = sphere

	return
cApp.prototype.AddCube = () ->
	@cubeClone = @cube.clone()
	@cubeClone.position.x = (Math.random()*Math.sqrt(@cubeNum)*@cubeSide) - (Math.sqrt(@cubeNum)*@cubeSide)/2
	@cubeClone.position.y = (Math.random()*Math.sqrt(@cubeNum)*@cubeSide) - (Math.sqrt(@cubeNum)*@cubeSide)/2
	@cubeClone.position.z = (Math.random()*Math.sqrt(@cubeNum)*@cubeSide) - (Math.sqrt(@cubeNum)*@cubeSide)/2

	j = 0
	while j <= 11
		@arrLines.push( @cubeClone.children[j] )
		j++

	i = 12
	while i <= 19
		@arrSpheres.push( @cubeClone.children[i] )
		i++
	@scene.add( @cubeClone )
	return

## RUN THE PROJECT
cApp.prototype.Run = () ->
	console.info 'Project is running!'

	self = @
	@scene = new THREE.Scene()

	@PlaneInit()
	@CreateCube()

	i = 0
	while i<@cubeNum
		@AddCube()
		i++

	@CameraInit()
	@RenderInit()

	axes = new THREE.AxisHelper( 100 )
	@scene.add(axes)

	window.addEventListener( 'resize', App.onWindowResize.bind(self), false )
	document.getElementById("webgl").appendChild(@renderer.domElement)

	@orbit = new THREE.OrbitControls(@camera)
	@Rendering()

	return

################
### APP start###
################
App = new cApp()
window.onload = App.Run()

document.onmousedown = (event)->
	App.MouseDownEvent(event)
	return
document.onmouseup = ()->
	App.MouseUpEvent()
	return
