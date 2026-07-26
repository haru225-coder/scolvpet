/// <reference types="@tarojs/taro" />

declare module '*.png'
declare module '*.gif'
declare module '*.jpg'
declare module '*.jpeg'
declare module '*.svg'
declare module '*.css'
declare module '*.less'
declare module '*.scss'

declare namespace NodeJS {
  interface ProcessEnv {
    /** weapp | h5 */
    TARO_ENV: 'weapp' | 'h5'
  }
}

// 原生混写层直接触达 wx API(app.ts 移植旧 app.js 逻辑);
// Taro 侧业务代码请一律用 @tarojs/taro,不要扩散 wx 直呼。
declare const wx: any
