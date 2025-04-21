
interface Env {
	R2: R2Bucket;
	KV: KVNamespace;
	USERNAME:string;
	PASSWORD:string;
}
function getMimeType(extenstion:string):string {
	const mimeType:{[key:string]:string}={
		'jpg': 'image/jpeg',
		'jpeg': 'image/jpeg',
		'png': 'image/png',
		'gif': 'image/gif',
		'webp': 'image/webp',
		'svg': 'image/svg+xml',
		'bmp': 'image/bmp',
		'tiff': 'image/tiff',
		'ico': 'image/x-icon',
		'heic': 'image/heic',
		'heif': 'image/heif'
	}
	return  mimeType[extenstion.toLowerCase()]||'application/octet-stream';
}
function verifyBasicAuth(request:Request, env:Env	):boolean {
	const  authHeader=request.headers.get('Authorization');
	if (!authHeader || !authHeader.startsWith('Basic ')) {
		return false;
	}
	const basic64Credentials=authHeader.split(' ')[1];
	const credentials=atob(basic64Credentials);
	const [username,password] = credentials.split(':');
	return username === env.USERNAME&&password === env.PASSWORD;
}
export default {
	async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
		const url = new URL(request.url);
		if (url.pathname === '/upload' && request.method === 'POST') {
			if (!verifyBasicAuth(request, env)) {
				return new Response('Unauthorized', {status: 401,headers:{
					'WWW-Requested-With': 'Basic realm="file Upload"',
					}});
			}
			try {
				const formData = await request.formData();
				const file = formData.get('file') as File;
				if (!file) {
					return new Response('no file provided', { status: 400 });
				}
				const now = new Date();
				const year = now.getFullYear();
				const month = String(now.getMonth() + 1).padStart(2, '0');
				const day = String(now.getDate()).padStart(2, '0');
				const uuid = crypto.randomUUID();
				const extension = file.name.split('.').pop();
				const path = `${year}/${month}/${day}/${uuid}.${extension}`;
				await env.R2.put(path, file);
				await env.KV.put(path, '0');
				return new Response(path, { status: 200 });
			} catch (err) {
				return new Response('error', { status: 500 });
			}
		}
		if (url.pathname.startsWith('/i/') && request.method === 'GET') {
			const cacheKey=new Request(url.toString(),{method:'GET'});
			const cache=caches.default
			let response = await cache.match(cacheKey)
			if (response){
				return response;
			}


			const path = url.pathname.slice(3);
			const views = await env.KV.get(path);
			if (views === null) {
				return new Response('not found', { status: 404 });
			}
			const file = await env.R2.get(path);
			if (!file) {
				return new Response('not found', { status: 404 });
			}
			const newViews = parseInt(views) + 1;
			ctx.waitUntil(env.KV.put(path, newViews.toString()));
			const extension = path.split('.').pop()||''
			const contentType=getMimeType(extension)

			response=new Response(file.body, {
				status: 200,
				headers: {
					'Content-Type': contentType,
					'Cache-Control': 'public, max-age=31536000, immutable'
				}
			})
			ctx.waitUntil(cache.put(cacheKey,response.clone()))
			return response;
		}
		return new Response('not found', { status: 404 });
	}
} satisfies ExportedHandler<Env>;
