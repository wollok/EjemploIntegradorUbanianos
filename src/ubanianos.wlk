object usuarioBaneado inherits Exception("Su usuario ha sido baneado, no puede comentar") {}
object noEsElCreador inherits Exception("El usuario no es el crador del tema") {}
object temaCerrado inherits Exception("El tema esta cerrado, no se puede comentar") {}
object sinPermiso inherits Exception("El usuario no posee los permisos para realizar la accion"){}

class Usuario {
		var casosCerrados = 0
		var property rango = novato
		var property estado = activo
		var property puntosActuales = foro.puntosIniciales()
		
		method publicarTema(tituloNuevo, contenidoNuevo, categoriaNueva){
			foro.agregarTema(new Tema(creador = self, titulo = tituloNuevo, contenido = contenidoNuevo, categoria = categoriaNueva))
		}
		method agregarEtiquetas(tema, etiqueta){
			if (!tema.publicadoPor(self))
				throw noEsElCreador
			tema.agregarEtiqueta(etiqueta)
		}
		method comentar(tema, contenidoNuevo){
			tema.validarAbierto()
			estado.comentar(tema, contenidoNuevo, self)
		}
		method aumentarPuntos(cantidad){
			puntosActuales += rango.cuantosPuntosOtorga(cantidad)
		}
		method citar(tema, comentario, contenidoNuevo){
			tema.validarAbierto()
			estado.citarComentario(tema, comentario, contenidoNuevo, self)
		}
		method cerrarTema(tema){
			rango.cerrarTema(tema, self)
		}
		method puntosTotales(){
			return foro.puntosIniciales() + self.puntosGanados()
		}
		method puntosGanados(){
			return puntosActuales - foro.puntosIniciales()
		}
		method quitarPuntosIniciales(){
			puntosActuales -= foro.puntosIniciales()
		}
	
		method banear(){
			estado= baneado
			self.quitarPuntosIniciales()
		}
		
		method nuncaCerroCasos() {
			return casosCerrados == 0
		}
	
}

object activo {
	
		method comentar(tema, contenidoNuevo, usuario){
			tema.agregarComentario(new Comentario(creador = usuario, contenido = contenidoNuevo))
		}
		method citarComentario(tema, comentario, contenidoNuevo, usuario){
			tema.agregarComentario(new Cita(creador = usuario, contenido = contenidoNuevo, comentarioCitado = comentario))
			comentario.puntuarCreador()
		}
}

object baneado {
		
	method comentar(tema, contenidoNuevo, usuario){
		throw usuarioBaneado
	}	
	method citarComentario(tema, comentario, contenidoNuevo, usuario){
		throw usuarioBaneado		
	}
}

object novato{
		
	method cerrarTema(tema, usuario){
		throw sinPermiso 
	}
	method cuantosPuntosOtorga(cantidad){
		return cantidad
	}
	
}

object admin{
		
		method cerrarTema(tema,usuario){
			tema.cerrar()
			usuario.aumentarCasosCerrados()
		}
		method cuantosPuntosOtorga(cantidad){
			return cantidad*2
		}
}

object foro{
	
	var property puntosIniciales
	var property puntosPorComentar
	var property temas = []
	var property usuarios = []
	
	method agregarTema(tema){
		temas.add(tema)
	}
	method registrarUsuario(usuario){
		usuarios.add(usuario)
		usuario.aumentarPuntos(puntosIniciales)
	}
	method ascenderUsuarios(){
		self.usuarioConMasPuntos().rango(admin)
	}
	method usuarioConMasPuntos(){
		return usuarios.max{usuario => usuario.puntosActuales()}
	}
	method degradarUsuarios(){
		usuarios.forEach{usuario => self.degradar(usuario)}
	}
	method degradar(usuario){
		if(usuario.nuncaCerroCasos())
			usuario.rango(novato)
	}
	method banearUsuarios() {
		temas.forEach{tema => tema.banearTroll()}
	}
}

class Tema {
	var abierto = true
	var property creador
	var property titulo 
	var property contenido
	var property categoria
	const etiquetas = []
	const comentarios = []
	
	method agregarEtiqueta(etiqueta){
		etiquetas.add(etiqueta)
	}
	method agregarComentario(comentario){
		comentarios.add(comentario)
		creador.aumentarPuntos(foro.puntosPorComentar())
	}
	method validarAbierto() {
		if (!abierto)
			throw temaCerrado
	}
	method publicadoPor(usuario){
		return creador == usuario
	}
	method banearTroll(){
		comentarios.first().banear()				
	}
 	method cerrar(){
		abierto = false
		creador.quitarPuntos(foro.puntosIniciales())
	}
}

class Comentario{
	var property creador
	var property contenido 
	
//	method agregarComentario(tema){
//		tema.agregarComentario(self)
//	}
	method autorOriginal() {
		return creador
	}
	method banear(){
		if (contenido.contains("soyez le premier"))
			creador.banear() 
	}
	method puntuarCreador(){
		creador.aumentarPuntos(foro.puntosPorComentar())
	}
}

class Cita inherits Comentario{
	var property comentarioCitado 

	override method autorOriginal(){
		return comentarioCitado.autorOriginal()
	}
}
