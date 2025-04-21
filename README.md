### 项目名称
imgbed
### 简述
这个是一个图床，图片存储在cloudflare的r2，使用cloudflare worker作为后端。只有上传和下载图片两个功能。使用basic auth作为验证。强制缓存。使用kv防止r2随机路径404造成B类操作过多。  
前端目前只写了flutter的windows部分。
### 前端截图
![首页](img/index.png)
![设置页](img/setting.png)