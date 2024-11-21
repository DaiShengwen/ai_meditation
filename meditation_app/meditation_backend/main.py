from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
import random
import json

app = FastAPI()

# 添加静态文件服务
app.mount("/static", StaticFiles(directory="static"), name="static")

# CORS 配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Mood(BaseModel):
    id: str
    name: str
    description: Optional[str] = None
    isSelected: bool

class MeditationRequest(BaseModel):
    moods: List[Mood]
    description: Optional[str] = None

# 针对不同情绪的引导词模板
MOOD_TEMPLATES = {
    "焦虑": [
        "让我们先深呼吸三次。感受空气缓缓流入身体,带走紧张和焦虑...",
        "承认焦虑的存在是很勇敢的。让我们一起面对这份感受,不评判它...",
        "把注意力放在当下,观察你的呼吸。焦虑就像天上的云,会慢慢飘过..."
    ],
    "压力": [
        "感受双脚踏在地面的重量,让压力通过脚底流入大地...",
        "肩膀和脖子可能积累了不少压力,让我们轻轻活动它们...",
        "压力之下也蕴含着力量,让我们找到内心的平静..."
    ],
    "疲惫": [
        "不需要改变任何事,就让身体保持现在的姿势,休息片刻...",
        "疲惫是身体给我们的信号,让我们温柔地回应它...",
        "想象温暖的阳光洒在身上,为你补充能量..."
    ],
    "困惑": [
        "困惑也是一种智慧,它提醒我们需要停下来思考...",
        "让思绪就像溪流中的落叶,自然地流动...",
        "保持觉知,但不执着于任何想法,让头脑慢慢清晰..."
    ],
    "平静": [
        "觉察此刻的平静,让这份宁静延续下去...",
        "感恩当下的平和,这是内在智慧的展现...",
        "平静如同深海,任何波澜都无法撼动..."
    ],
    "开心": [
        "让喜悦的能量流遍全身,感受生命的美好...",
        "带着微笑,感恩这美好的时刻...",
        "快乐是内在的阳光,让它温暖你的心灵..."
    ]
}

# 通用的开场白
INTROS = [
    "找一个舒适的姿势坐下或躺下。",
    "让我们用几分钟的时间,关注内在的感受。",
    "闭上眼睛,或将视线柔和地落在前方。"
]

# 通用的结束语
ENDINGS = [
    "慢慢地,让意识回到当下。感谢自己花时间关注内心。",
    "深吸一口气,然后缓缓呼出。让平和的能量伴随着你。",
    "轻轻活动手指和脚趾,带着平静的心重返日常。"
]

@app.post("/generate-meditation")
async def generate_meditation(request: MeditationRequest):
    try:
        print(f"\n=== 开始处理请求 ===")
        print(f"收到的情绪: {[mood.name for mood in request.moods if mood.isSelected]}")
        
        selected_moods = [mood for mood in request.moods if mood.isSelected]
        if not selected_moods:
            raise HTTPException(status_code=400, detail="请至少选择一种情绪")
        
        # 生成冥想文本
        meditation_text = random.choice(INTROS) + "\n\n"
        print(f"选择的开场白: {meditation_text}")
        
        # 根据选中的情绪组合内容
        mood_texts = []
        for mood in selected_moods:
            if mood.name in MOOD_TEMPLATES:
                selected_text = random.choice(MOOD_TEMPLATES[mood.name])
                mood_texts.append(selected_text)
                print(f"情绪 '{mood.name}' 选择的文本: {selected_text}")
        
        meditation_text += "\n\n".join(mood_texts) + "\n\n"
        
        if request.description:
            additional_text = f"我理解你说的'{request.description}'。让我们一起面对这些感受。\n\n"
            meditation_text += additional_text
            print(f"添加的描述文本: {additional_text}")
        
        meditation_text += random.choice(ENDINGS)
        print(f"选择的结束语: {random.choice(ENDINGS)}")
        
        response_data = {
            "text": meditation_text,
            "audioUrl": "http://127.0.0.1:8000/static/meditation_sample.mp3"
        }
        
        print(f"\n最终生成的文本: {meditation_text}")
        
        # 直接返回字典，让 FastAPI 处理序列化
        return response_data
        
    except Exception as e:
        print(f"错误: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def read_root():
    return {"message": "Meditation API is running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app, 
        host="127.0.0.1",
        port=8000,
        log_level="debug"
    )
