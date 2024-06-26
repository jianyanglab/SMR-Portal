interface UserTenant {
  symbol: symbol
  id: string
  name: string
  type: string
  datadir?: string
}

interface User {
  symbol: symbol
  id: string
  tenantId: string
  email: string
  name: string
  company: string
  tenants: UserTenant[]
}
