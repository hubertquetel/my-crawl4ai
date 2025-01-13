from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import asyncio
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig
from typing import List, Union

app = FastAPI()

class CrawlRequest(BaseModel):
    urls: Union[str, List[str]]
    priority: int = 1

@app.post("/crawl")
async def crawl(request: CrawlRequest):
    try:
        browser_config = BrowserConfig(
            headless=True,
            verbose=True
        )
        
        async with AsyncWebCrawler(config=browser_config) as crawler:
            if isinstance(request.urls, str):
                urls = [request.urls]
            else:
                urls = request.urls
                
            results = []
            for url in urls:
                result = await crawler.arun(url=url)
                results.append({
                    "url": url,
                    "markdown": result.markdown,
                    "fit_markdown": result.fit_markdown
                })
                
            return {"status": "success", "results": results}
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=11235)
