import { Controller } from "@hotwired/stimulus"

// Butterfly Navigation Controller
// Connects to data-controller="butterfly"
export default class extends Controller {
  static targets = ["container"]
  static values = { 
    level: String,
    enabled: { type: Boolean, default: true }
  }

  connect() {
    this.butterfly = null
    this.trail = []
    this.maxTrailLength = 8
    this.isFlying = false
    
    if (this.enabledValue) {
      this.createButterfly()
      this.bindEvents()
    }
  }

  disconnect() {
    this.cleanup()
  }

  createButterfly() {
    // Create butterfly element
    this.butterfly = document.createElement('div')
    this.butterfly.className = `navigation-butterfly flying level-${this.levelValue || 'topic'}`
    
    // Create butterfly structure
    this.butterfly.innerHTML = `
      <div class="butterfly-body"></div>
      <div class="butterfly-wing-left"></div>
      <div class="butterfly-wing-right"></div>
    `
    
    document.body.appendChild(this.butterfly)
    console.log('[Butterfly] Created for level:', this.levelValue, 'Element:', this.butterfly)
  }

  bindEvents() {
    // Listen for navigation clicks on expandable headers and links
    document.addEventListener('click', this.handleNavigationClick.bind(this))
    
    // Listen for mouse movement to create subtle following effect
    document.addEventListener('mousemove', this.handleMouseMove.bind(this))
    
    // Listen for expandable state changes
    document.addEventListener('expandable:opened', this.handleExpandableOpened.bind(this))
    document.addEventListener('expandable:closed', this.handleExpandableClosed.bind(this))
  }

  handleNavigationClick(event) {
    if (!this.enabledValue || this.isFlying) return
    
    const target = event.target.closest('.expandable-header, .link, a[href]')
    if (!target) return
    
    // Determine navigation level and destination
    const level = this.determineNavigationLevel(target)
    const destination = this.getDestinationPosition(target)
    
    if (destination) {
      this.flyTo(destination, level)
    }
  }

  handleMouseMove(event) {
    if (!this.enabledValue || this.isFlying) return
    
    // Subtle butterfly following effect (much slower than direct movement)
    const mouseX = event.clientX
    const mouseY = event.clientY
    
    // Only follow if mouse is near navigation elements
    const navElement = event.target.closest('.expandable-header, .navigation, .breadcrumb-chain')
    if (navElement && this.butterfly) {
      this.subtleFollow(mouseX, mouseY)
    }
  }

  handleExpandableOpened(event) {
    if (!this.enabledValue) return
    
    const expandableContent = event.target.querySelector('.expandable-content')
    if (expandableContent) {
      const rect = expandableContent.getBoundingClientRect()
      const centerX = rect.left + rect.width / 2
      const centerY = rect.top + rect.height / 2
      
      this.flyTo({ x: centerX, y: centerY }, 'expanded')
    }
  }

  handleExpandableClosed(event) {
    if (!this.enabledValue) return
    
    // Fly back to header when collapsed
    const header = event.target.querySelector('.expandable-header')
    if (header) {
      const destination = this.getDestinationPosition(header)
      if (destination) {
        this.flyTo(destination, 'collapsed')
      }
    }
  }

  determineNavigationLevel(element) {
    // Determine hierarchy level based on element context
    if (element.closest('.country-partial')) return 'country'
    if (element.closest('.state-partial')) return 'state'
    if (element.closest('.city-partial')) return 'city'
    if (element.closest('.topic-partial')) return 'topic'
    if (element.closest('.issue-partial')) return 'issue'
    if (element.closest('.approach-partial')) return 'approach'
    if (element.closest('.election-partial')) return 'election'
    
    return this.levelValue || 'topic'
  }

  getDestinationPosition(element) {
    const rect = element.getBoundingClientRect()
    
    // Use viewport coordinates for fixed positioning
    return {
      x: rect.left + rect.width / 2,
      y: rect.top + rect.height / 2
    }
  }

  flyTo(destination, level) {
    if (!this.butterfly || this.isFlying) return
    
    this.isFlying = true
    this.showButterfly()
    
    // Update butterfly level styling
    this.butterfly.className = `navigation-butterfly flying level-${level}`
    
    // Calculate flight path (bezier curve for natural movement)
    const start = this.getCurrentPosition()
    const controlPoint = this.calculateControlPoint(start, destination)
    
    console.log('[Butterfly] Flying from', start, 'to', destination, 'via', controlPoint)
    
    // Animate along bezier curve
    this.animateAlongPath(start, controlPoint, destination, level)
  }

  getCurrentPosition() {
    if (!this.butterfly) return { x: window.innerWidth / 2, y: window.innerHeight / 2 }
    
    const rect = this.butterfly.getBoundingClientRect()
    
    // Use viewport coordinates for fixed positioning
    return {
      x: rect.left + rect.width / 2,
      y: rect.top + rect.height / 2
    }
  }

  calculateControlPoint(start, end) {
    // Create a natural arc for the butterfly flight
    const midX = (start.x + end.x) / 2
    const midY = (start.y + end.y) / 2
    
    // Add some randomness and arc height
    const arcHeight = Math.min(100, Math.abs(end.y - start.y) * 0.5)
    const randomOffset = (Math.random() - 0.5) * 60
    
    return {
      x: midX + randomOffset,
      y: midY - arcHeight
    }
  }

  animateAlongPath(start, control, end, level) {
    const duration = 1200 // 1.2 seconds
    const startTime = performance.now()
    
    const animate = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      
      // Ease-out cubic for natural deceleration
      const easeProgress = 1 - Math.pow(1 - progress, 3)
      
      // Calculate position on bezier curve
      const position = this.bezierPoint(start, control, end, easeProgress)
      
      // Update butterfly position
      if (this.butterfly) {
        this.butterfly.style.left = `${position.x}px`
        this.butterfly.style.top = `${position.y}px`
        
        // Add rotation based on movement direction
        const rotation = this.calculateRotation(start, end, easeProgress)
        this.butterfly.style.transform = `translate(-50%, -50%) rotate(${rotation}deg)`
      }
      
      // Create sparkle trail
      if (progress > 0.1 && progress < 0.9) {
        this.createTrailSparkle(position)
      }
      
      if (progress < 1) {
        requestAnimationFrame(animate)
      } else {
        this.finishFlight(level)
      }
    }
    
    requestAnimationFrame(animate)
  }

  bezierPoint(start, control, end, t) {
    const x = Math.pow(1 - t, 2) * start.x + 2 * (1 - t) * t * control.x + Math.pow(t, 2) * end.x
    const y = Math.pow(1 - t, 2) * start.y + 2 * (1 - t) * t * control.y + Math.pow(t, 2) * end.y
    return { x, y }
  }

  calculateRotation(start, end, progress) {
    const dx = end.x - start.x
    const dy = end.y - start.y
    const angle = Math.atan2(dy, dx) * (180 / Math.PI)
    
    // Add some flutter variation
    const flutter = Math.sin(progress * Math.PI * 8) * 5
    return angle + flutter
  }

  createTrailSparkle(position) {
    const sparkle = document.createElement('div')
    sparkle.className = 'butterfly-trail sparkle'
    sparkle.style.left = `${position.x}px`
    sparkle.style.top = `${position.y}px`
    
    document.body.appendChild(sparkle)
    
    // Remove sparkle after animation
    setTimeout(() => {
      if (sparkle.parentNode) {
        sparkle.parentNode.removeChild(sparkle)
      }
    }, 1000)
    
    // Limit trail length
    this.trail.push(sparkle)
    if (this.trail.length > this.maxTrailLength) {
      const oldSparkle = this.trail.shift()
      if (oldSparkle && oldSparkle.parentNode) {
        oldSparkle.parentNode.removeChild(oldSparkle)
      }
    }
  }

  finishFlight(level) {
    this.isFlying = false
    
    if (this.butterfly) {
      // Celebration animation
      this.butterfly.classList.add('arrived')
      
      setTimeout(() => {
        if (this.butterfly) {
          this.butterfly.classList.remove('arrived')
          this.hideButterfly()
        }
      }, 1000)
    }
    
    console.log('[Butterfly] Arrived at', level)
  }

  subtleFollow(mouseX, mouseY) {
    if (!this.butterfly || this.isFlying) return
    
    const current = this.getCurrentPosition()
    const distance = Math.sqrt(Math.pow(mouseX - current.x, 2) + Math.pow(mouseY - current.y, 2))
    
    // Only follow if mouse is reasonably close and moving
    if (distance > 50 && distance < 300) {
      const followX = current.x + (mouseX - current.x) * 0.1
      const followY = current.y + (mouseY - current.y) * 0.1
      
      this.butterfly.style.left = `${followX}px`
      this.butterfly.style.top = `${followY}px`
    }
  }

  showButterfly() {
    if (this.butterfly) {
      this.butterfly.classList.remove('hidden')
      this.butterfly.classList.add('flying')
    }
  }

  hideButterfly() {
    if (this.butterfly) {
      this.butterfly.classList.remove('flying')
      // Stay visible longer to appreciate the animation
      setTimeout(() => {
        if (this.butterfly) {
          this.butterfly.classList.add('hidden')
        }
      }, 3000) // Hide after 3 seconds
    }
  }

  cleanup() {
    if (this.butterfly && this.butterfly.parentNode) {
      this.butterfly.parentNode.removeChild(this.butterfly)
    }
    
    // Clean up trail sparkles
    this.trail.forEach(sparkle => {
      if (sparkle && sparkle.parentNode) {
        sparkle.parentNode.removeChild(sparkle)
      }
    })
    
    this.trail = []
  }

  // Public methods for external control
  enable() {
    this.enabledValue = true
    if (!this.butterfly) {
      this.createButterfly()
    }
  }

  disable() {
    this.enabledValue = false
    this.hideButterfly()
  }

  changeLevel(newLevel) {
    this.levelValue = newLevel
    if (this.butterfly) {
      this.butterfly.className = `navigation-butterfly hidden level-${newLevel}`
    }
  }
}