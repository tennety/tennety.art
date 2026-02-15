declare module 'turndown' {
  class TurndownService {
    constructor(options?: any)
    turndown(html: string): string
  }

  export default TurndownService
}
