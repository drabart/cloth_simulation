float FRAMERATE = 60.0;


class Ball
{
  public PVector pos, prev_pos, force;
  public float mass, step, size;
  public int id;
  public boolean fixed, temp_fixed;
  
  public Ball(int id, PVector pos, PVector vel, float mass, float step)
  {
    this.id = id;
    this.step = step;
    this.pos = pos;
    this.mass = mass;
    prev_pos = this.pos.copy();
    this.pos.add(vel.mult(step));
    this.force = new PVector(0, 0);
    size = pow(mass, 1.0/3.0)*10.0;
    this.fixed = false;
    this.temp_fixed = false;
  }
  
  public void update()
  {
    // println(pos, prev_pos, fixed);
    if(fixed || temp_fixed)
    {
      this.force = new PVector(0, 0);
      return;
    }
    PVector acceleration = force.copy().div(mass);
    PVector temp = pos.copy();
    pos.mult(2.0).sub(prev_pos).add(acceleration.copy().mult(step * step));
    prev_pos = temp.copy();
    this.force = new PVector(0, 0);
  }
  
  public void render()
  {
    // println(this.pos);
    circle(pos.x, pos.y, size);
  }
}