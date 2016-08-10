'use strict';
###Class APP###
cApp = () ->
	this.cubeNum = 500
	this.cubeSide = 10
	this.sphereRadius = 10
	return
cApp.prototype.GetPropValue = (prop) ->
	return this[prop]
cApp.prototype.SetPropValue = (prop,value) ->
	this[prop] = value
	return
cApp.prototype.Run = () ->
	i = 0
	while i < this.cubeNum
		Cube = new cCube()
		Cube.Create(0,0,0)
		console.log Cube.x
		console.log Cube.y
		console.log Cube.z
		i++

###Class Cube###
cCube = () ->
	this.x = undefined
	this.y = undefined
	this.z = undefined
	return
cCube.prototype.Create = (x,y,z) ->
	this.x = x
	this.y = y
	this.z = z
	console.log 'created'
	return
App = new cApp()
##window.onload = App.Run();






scene = undefined
camera = undefined
renderer = undefined

num = 10
length = 10
radius = 0.5


x = y = z = undefined

arrPoints = []
arrLines = []

orbit = undefined
plane = undefined
selectedObject = undefined

projector = new THREE.Projector()
offset = new THREE.Vector3()

init = ()->

	scene = new THREE.Scene()

	plane = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 2000, 18, 18 ), new THREE.MeshBasicMaterial() )
	plane.visible = false
	scene.add( plane )


	cubeGeometry = new THREE.BoxGeometry(10, 10, 10);
	##cubeMaterial = new THREE.MeshLambertMaterial({color: Math.random() * 0xffffff});
	cubeMaterial = new THREE.MeshLambertMaterial({});
	cubeMaterial.transparent = true;
	cube = new THREE.Mesh(cubeGeometry, cubeMaterial);
	cube.visible = false
	console.log cube
	scene.add(cube);

	camera = new THREE.PerspectiveCamera(30, window.innerWidth / window.innerHeight, 0.1, 1000)
	camera.position.x = 100
	camera.position.y = 90
	camera.position.z = 90
	camera.lookAt(scene.position)

	renderer = new THREE.WebGLRenderer()
	renderer.setClearColor(new THREE.Color(0xEEEEEE))
	renderer.setSize(window.innerWidth, window.innerHeight)

	axes = new THREE.AxisHelper( 100 )
	scene.add(axes)

	##createElements()

	document.getElementById("WebGL-output").appendChild(renderer.domElement)

	window.addEventListener( 'resize', onWindowResize, false )

	orbit = new THREE.OrbitControls(camera)

	render()
	return

createElements = ()->
	k = 1
	while k <= num
		###
		x = Math.random() * (length + num + 30)
		y = Math.random() * (length + num + 30)
		z = Math.random() * (length + num + 30)
		###
		x = 0
		y = 0
		z = 0
		createBox x, y, z

		createBox(x, y, z+(length*k*1.5))
		createBox(x, y, -(z+(length*k*1.5)))

		###createBox(-x, -y, -z)
		createBox(x, -y, -z)
		createBox(-x, y, -z)
		createBox(-x, -y, z)

		createBox(x, y, -z)
		createBox(x, -y, z)
		createBox(-x, y, z)###
		k++

	i = 0
	while i < arrLines.length
		scene.add(arrLines[i])
		i++

	j = 0
	while j < arrPoints.length
		scene.add(arrPoints[j])
		j++
	return

createBox = (x,y,z) ->

	lineMaterial = new THREE.LineBasicMaterial({ color: 0x000000 })

	lineGeometries = {

		1:{ 1:{x:x+length/2,y:y+length/2,z:z-length/2}, 2:{x:x+length/2,y:y+length/2,z:z+length/2} },
		2:{ 1:{x:x+length/2,y:y+length/2,z:z-length/2}, 2:{x:x-length/2,y:y+length/2,z:z-length/2} },
		3:{ 1:{x:x+length/2,y:y+length/2,z:z-length/2}, 2:{x:x+length/2,y:y-length/2,z:z-length/2} },

		4:{ 1:{x:x-length/2,y:y-length/2,z:z-length/2}, 2:{x:x+length/2,y:y-length/2,z:z-length/2} },
		5:{ 1:{x:x-length/2,y:y-length/2,z:z-length/2}, 2:{x:x-length/2,y:y+length/2,z:z-length/2} },
		6:{ 1:{x:x-length/2,y:y-length/2,z:z-length/2}, 2:{x:x-length/2,y:y-length/2,z:z+length/2} }

		7:{ 1:{x:x-length/2,y:y+length/2,z:z+length/2}, 2:{x:x+length/2,y:y+length/2,z:z+length/2} },
		8:{ 1:{x:x-length/2,y:y+length/2,z:z+length/2}, 2:{x:x-length/2,y:y-length/2,z:z+length/2} },
		9:{ 1:{x:x-length/2,y:y+length/2,z:z+length/2}, 2:{x:x-length/2,y:y+length/2,z:z-length/2} }

		10:{ 1:{x:x+length/2,y:y-length/2,z:z+length/2}, 2:{x:x-length/2,y:y-length/2,z:z+length/2} },
		11:{ 1:{x:x+length/2,y:y-length/2,z:z+length/2}, 2:{x:x+length/2,y:y+length/2,z:z+length/2} },
		12:{ 1:{x:x+length/2,y:y-length/2,z:z+length/2}, 2:{x:x+length/2,y:y-length/2,z:z-length/2} }
	}

	i = 1
	while i <= 12
		lineCoords = lineGeometries[i]
		lineGeometry = new THREE.Geometry()
		lineGeometry.vertices.push(
			new THREE.Vector3( lineCoords[1].x, lineCoords[1].y, lineCoords[1].z ),
			new THREE.Vector3( lineCoords[2].x, lineCoords[2].y, lineCoords[2].z )
		)
		line = new THREE.Line( lineGeometry, lineMaterial )

		arrLines.push( line )
		i++
	createPoints(x,y,z)


createPoints = (x,y,z)->

	objPoint = {
		1: {x:x-length/2,y:y-length/2,z:z-length/2,color:0xc0f515},
		2: {x:x+length/2,y:y+length/2,z:z+length/2,color:0x8d6796},
		3: {x:x+length/2,y:y-length/2,z:z-length/2,color:0xdd1600},
		4: {x:x-length/2,y:y+length/2,z:z-length/2,color:0x1c1aa9},
		5: {x:x-length/2,y:y-length/2,z:z+length/2,color:0x6e400a},
		6: {x:x+length/2,y:y+length/2,z:z-length/2,color:0x5f2c4f},
		7: {x:x-length/2,y:y+length/2,z:z+length/2,color:0x82d481},
		8: {x:x+length/2,y:y-length/2,z:z+length/2,color:0x46173d}
	};

	pointGeometry = new THREE.SphereGeometry( radius )
	i = 1
	while i <= 8
		pointMaterial = new THREE.MeshBasicMaterial( {color: objPoint[i].color} )

		point = new THREE.Mesh( pointGeometry, pointMaterial )
		point.position.x = objPoint[i].x
		point.position.y = objPoint[i].y
		point.position.z = objPoint[i].z

		arrPoints.push(point)
		i++

	return

document.onmousedown = (event)->

	mouse_x = ( event.clientX / window.innerWidth ) * 2 - 1;
	mouse_y = -( event.clientY / window.innerHeight ) * 2 + 1;

	vector = new THREE.Vector3(mouse_x, mouse_y, 0.5);

	vector.unproject(camera);

	raycaster = new THREE.Raycaster(camera.position, vector.sub(camera.position).normalize());

	intersects = raycaster.intersectObjects(arrPoints);

	if intersects.length > 0

		orbit.enabled = false
		selectedObject = intersects[0].object
		position = selectedObject.position

		i = 0
		while i < arrLines.length
			j = 0
			while j < 2
				if position.x == arrLines[i].geometry.vertices[j].x && position.y == arrLines[i].geometry.vertices[j].y && position.z == arrLines[i].geometry.vertices[j].z
					arrLines[i].material = selectedObject.material
				j++
			i++
	return

document.onmouseup = ()->
	orbit.enabled = true
	selectedObject = null

render = ()->
	renderer.render(scene, camera)
	orbit.update()
	requestAnimationFrame(render)
	return

onWindowResize = () ->
	camera.aspect = window.innerWidth / window.innerHeight;
	camera.updateProjectionMatrix();
	renderer.setSize( window.innerWidth, window.innerHeight );
	return

window.onload = init;