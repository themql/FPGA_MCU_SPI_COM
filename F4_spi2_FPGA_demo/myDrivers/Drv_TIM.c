#include "Drv_TIM.h"


#define TIM_DELAYUS (htim6)
extern TIM_HandleTypeDef TIM_DELAYUS;


void delay_US(uint16_t us)
{
  uint16_t differ=0xffff-us-5;

  __HAL_TIM_SET_COUNTER(&TIM_DELAYUS,differ);
  HAL_TIM_Base_Start(&TIM_DELAYUS);
  while(differ<0xffff-6)
  {
    differ=__HAL_TIM_GET_COUNTER(&TIM_DELAYUS);
  }
  HAL_TIM_Base_Stop(&TIM_DELAYUS);

}


//#define USE_LVGL
#ifdef USE_LVGL

// lvgl std clk
extern TIM_HandleTypeDef htim7;
extern void lv_tick_inc(uint32_t tick_period);

#define DEBUG_PrintInfo
#ifdef DEBUG_PrintInfo
#include "stdio.h"
uint32_t tick_cnt=0;
#endif

#endif

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
#ifdef USE_LVGL
  if(htim == &htim7)
  {
    lv_tick_inc(1);
#ifdef DEBUG_PrintInfo
    if(tick_cnt < 1000)
    {
      tick_cnt++;
    }
    else
    {
      tick_cnt = 0;
      printf("tick 1000\n");
    }
#endif
  }
#endif
}