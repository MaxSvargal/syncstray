import { camelizeKeys } from 'humps'

export const putVkCode = (code: string) =>
  localStorage.setItem('vkCode', code)

export const getVkCode = () =>
  localStorage.getItem('vkCode')

export const putVkToken = (token: string, expiresIn: number) => {
  localStorage.setItem('vkToken', token)
  localStorage.setItem('vkTokenExpiresIn', new Date().getTime() + (expiresIn * 1000))
}

export const getVkToken = () => {
  const token = localStorage.getItem('vkToken')
  const expiresIn = Number(localStorage.getItem('vkTokenExpiresIn'))
  const nowTime = new Date().getTime()
  return nowTime <= expiresIn ? token : null
}

export const fetchVkToken = (code: string) =>
  fetch(`https://oauth.vk.com/access_token?client_id=4138123&client_secret=9c7G6T5bZkVE097J3AMI&code=${code}`)
    .then(resp => resp.json())
    .then(json => camelizeKeys(json))

export const fetchVkAudio = (token: string) =>
  fetch(`https://api.vk.com/method/audio.get?access_token=${token}`)
    .then(resp => resp.json())
    .then(json => camelizeKeys(json.response))
