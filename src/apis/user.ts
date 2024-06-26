import axios from './axios'
import { api as base } from '@/config'

export async function signin(email: string, password: string) {
  const { data } = await axios.post <Response<{ token: string }>>(`${base}/user/signin`, {
    email,
    pwd: password,
  })
  return data.data.token
}

export async function signup({
  email,
  password,
  name,
  company,
}: {
  email: string
  password: string
  name: string
  company?: string
}) {
  const { data } = await axios.post <Response<{ id: string }>>(`${base}/user/signup`, {
    email,
    pwd: password,
    user_name: name,
    company,
  })
  return data.data.id
}

export async function changePassword(oldPassword: string, newPassword: string) {
  await axios.post(`${base}/user/change-password`, {
    old_pwd: oldPassword,
    new_pwd: newPassword,
  })
}

export async function resetPassword(token: string, email: string, newPassword: string) {
  await axios.post(`${base}/user/password-reset/${token}`, {
    email,
    new_pwd: newPassword,
  })
}

export async function sendResetEmail(email: string) {
  await axios.post(`${base}/user/send-reset-email`, {
    email,
  })
}

export async function activate(token: string) {
  await axios.get(`${base}/user/activate/${token}`)
}

interface ServerUserTenant {
  id: string
  name: string
  type: string
  datadir?: string
}
interface ServerUser {
  id: string
  tenant_id: string
  email: string
  user_name: string
  company: string
  tenants: ServerUserTenant[]
}

export async function profile() {
  const { data } = await axios.get <Response<ServerUser>>(`${base}/user/profile`, {
    timeout: 3000,
  })
  return {
    symbol: Symbol('user'),
    id: data.data.id,
    tenantId: data.data.tenant_id,
    email: data.data.email,
    name: data.data.user_name,
    company: data.data.company,
    tenants: (data.data.tenants || []).map(tenant => ({
      symbol: Symbol('tenant'),
      id: tenant.id,
      name: tenant.name,
      type: tenant.type as 'personal' | 'organization',
      datadir: tenant.datadir,
    })),
  } as User
}
