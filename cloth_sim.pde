import java.util.Map;

float STEP_SIZE = 1.0 / 10q0.0;
float VEL_COEF = 1.0 / 1.0;
float GRAV_COEF = 100000.0;
float SIMPLE_GRAVITY_COEF = 500;
int JACOBIAN_COEF = 10;
float SPRING_COEF = 1.5;
float MAX_STRETCH = 1.2;
float MIN_STRETCH = 0.1;
float MASS = 3.0;
float EPS = 1.0 / 10000.0;
/*
(without render)
with 10 JK MAX 6,4k balls
with 5 JK MAX 10k balls
with 2 JK MAX 20k balls
*/
int HEIGHT = 80;
int WIDTH = 80;

HashMap<Integer, Ball> balls = new HashMap<Integer, Ball>();
IntList destroyed = new IntList();
ArrayList<Constraint> constraints = new ArrayList<Constraint>();
ArrayList<Force> forces = new ArrayList<Force>();
PVector pos_c1, pos_c2;
int ball_id;

Ball addBall(PVector pos, PVector vel, float mass)
{
	Ball new_ball = new Ball(ball_id, pos.copy(), vel.copy(), mass, STEP_SIZE);

	Force fr = new Force(ball_id, ForceType.SIMPLE_GRAVITY, -100.0);
	forces.add(fr);

	for(Ball ball : balls.values())
	{
		Constraint con = new Constraint(ball_id, ball.id, ConstraintType.CLOSER_MERGE, (ball.size + new_ball.size) / 1.9);
		constraints.add(con);

		// Force fr = new Force(ball_id, ball.id, ForceType.SPRING, 1, new_ball.pos.dist(ball.pos));
		// forces.add(fr);

		// Force fr = new Force(ball_id, ball.id, ForceType.GRAVITY, GRAV_COEF);
		// forces.add(fr);
	}
	
	balls.put(ball_id, new_ball);
	ball_id += 1;
	destroyed.append(0);
	
	return new_ball;
}

boolean pressed;
boolean carryingBall;
Ball pressedBall;

void mousePressed()
{
	pos_c1 = new PVector(mouseX, mouseY);
	pressed = true;
	for(Ball ball : balls.values())
	{
		if(ball.pos.dist(pos_c1) < ball.size / 2)
		{
			ball.temp_fixed = true;
			pressedBall = ball;
			carryingBall = true;
		}
	}
}

void mouseReleased()
{
	if(!pressed)
	{
		pressed = false;
		return;
	}
		
	pressed = false;
	if(carryingBall)
	{
		pressedBall.prev_pos = pressedBall.pos.copy();
		// println(pressedBall.pos);
		pressedBall.temp_fixed = false;
		carryingBall = false;
		return;
	}
	/*
	pos_c2.x = mouseX;
	pos_c2.y = mouseY;
	pos_c2.sub(pos_c1).mult(VEL_COEF);
	addBall(pos_c1.copy(), pos_c2.copy(), 1.0);
	pos_c1.x = -1;
	*/
}

void setup()
{
	long begin = System.nanoTime();

	pos_c1 = new PVector(-1, 0);
	pos_c2 = new PVector(-1, 0);
	ball_id = 0;

	float ver_pad = height / 4.0* 3.0;
	float hor_pad = width / 4.0 * 3.0;
	float ver_dist = (height - 2.0 * ver_pad) / (HEIGHT - 1);
	float hor_dist = (width - 2.0 * hor_pad) / (WIDTH - 1);
	PVector pos = new PVector(0, 0);

	for(int i=0; i<HEIGHT; ++i)
	{
		for(int j=0; j<WIDTH; ++j)
		{
			pos.x = hor_pad + hor_dist * j;
			pos.y = height - ver_pad - ver_dist * i;
			Ball new_ball = new Ball(ball_id, pos.copy(), new PVector(0, 0), MASS, STEP_SIZE);

			Force fr = new Force(ball_id, ForceType.SIMPLE_GRAVITY, -SIMPLE_GRAVITY_COEF);
			forces.add(fr);
			Constraint con;

			if(i != 0)
			{
				Ball ball = balls.get(ball_id - WIDTH);
				fr = new Force(ball_id, ball.id, ForceType.SPRING, SPRING_COEF, new_ball.pos.dist(ball.pos));
				forces.add(fr);
				con = new Constraint(ball_id, ball.id, ConstraintType.FURTHER, new_ball.pos.dist(ball.pos) * MAX_STRETCH);
				constraints.add(con);
				con = new Constraint(ball_id, ball.id, ConstraintType.CLOSER, new_ball.pos.dist(ball.pos) * MIN_STRETCH);
				constraints.add(con);
			}
			if(j != 0)
			{
				Ball ball = balls.get(ball_id - 1);
				fr = new Force(ball_id, ball.id, ForceType.SPRING, SPRING_COEF, new_ball.pos.dist(ball.pos));
				forces.add(fr);
				con = new Constraint(ball_id, ball.id, ConstraintType.FURTHER, new_ball.pos.dist(ball.pos) * MAX_STRETCH);
				constraints.add(con);
				con = new Constraint(ball_id, ball.id, ConstraintType.CLOSER, new_ball.pos.dist(ball.pos) * MIN_STRETCH);
				constraints.add(con);
			}
			if(i != 0 && j != 0)
			{
				Ball ball = balls.get(ball_id - 1 - WIDTH);
				fr = new Force(ball_id, ball.id, ForceType.SPRING, SPRING_COEF, new_ball.pos.dist(ball.pos));
				forces.add(fr);
				con = new Constraint(ball_id, ball.id, ConstraintType.FURTHER, new_ball.pos.dist(ball.pos) * MAX_STRETCH);
				constraints.add(con);
				con = new Constraint(ball_id, ball.id, ConstraintType.CLOSER, new_ball.pos.dist(ball.pos) * MIN_STRETCH);
				constraints.add(con);
			}
			if(i != 0 && j != WIDTH-1)
			{
				Ball ball = balls.get(ball_id + 1 - WIDTH);
				fr = new Force(ball_id, ball.id, ForceType.SPRING, SPRING_COEF, new_ball.pos.dist(ball.pos));
				forces.add(fr);
				con = new Constraint(ball_id, ball.id, ConstraintType.FURTHER, new_ball.pos.dist(ball.pos) * MAX_STRETCH);
				constraints.add(con);
				con = new Constraint(ball_id, ball.id, ConstraintType.CLOSER, new_ball.pos.dist(ball.pos) * MIN_STRETCH);
				constraints.add(con);
			}
			
			if(i == 0 && (j == 0 || j == WIDTH-1))
				new_ball.fixed = true;

			balls.put(ball_id, new_ball);
			ball_id += 1;
			destroyed.append(0);
		}
	}
	
	fill(0);
	stroke(5);
	
	fullScreen();
	frameRate(60);

	long end = System.nanoTime();          
	long time = end-begin;
	System.out.println("Setup Elapsed Time: "+time / 1000000.0+"ms");
}

void mergeBalls(Ball ball1, Ball ball2)
{
	float m1 = ball1.mass;
	float m2 = ball2.mass;
	PVector pos1 = ball1.pos.copy();
	PVector pos2 = ball2.pos.copy();
	PVector pos = pos1.mult(m1).add(pos2.mult(m2)).div(m1+m2);
	PVector vel = new PVector(0, 0);
	PVector pp1 = ball1.prev_pos.copy();
	PVector pp2 = ball2.prev_pos.copy();
	PVector prev_pos = pp1.mult(m1).add(pp2.mult(m2)).div(m1+m2);
	float mass = m1 + m2;
	destroyed.set(ball1.id, 1);
	destroyed.set(ball2.id, 1);
	balls.remove(ball1.id);
	balls.remove(ball2.id);
	Ball new_ball = addBall(pos, vel, mass);
	new_ball.prev_pos = prev_pos;
}

// process forces
void processForces()
{
	// iterate over every force
	for(int i=0; i<forces.size(); ++i)
	{
		// get force
		Force force_o = forces.get(i);
		int id1 = force_o.id_ball_1;
		int id2 = force_o.id_ball_2;
		// check if it has not been destroyed
		if(force_o.type == ForceType.SIMPLE_GRAVITY)
		{
			if(destroyed.get(id1) == 1)
			{
				forces.remove(i);
				i--;
				continue;
			}
			Ball ball1 = balls.get(id1);
			PVector pos1 = ball1.pos.copy();
			float mass1 = ball1.mass;
			PVector force = force_o.force(pos1, pos1, mass1, mass1);

			ball1.force.add(force);
		}
		else
		{
			if(destroyed.get(id1) == 1 || destroyed.get(id2) == 1)
			{
				forces.remove(i);
				i--;
				continue;
			}
			Ball ball1 = balls.get(id1);
			Ball ball2 = balls.get(id2);
			PVector pos1 = ball1.pos.copy();
			PVector pos2 = ball2.pos.copy();
			float mass1 = ball1.mass;
			float mass2 = ball2.mass;
			PVector force = force_o.force(pos1, pos2, mass1, mass2);

			ball1.force.add(force);
			ball2.force.add(force.mult(-1));
		}
	}
}

// process Jacobian once
void processJacobian()
{
	// iterate over every constraint
	for(int i=0; i<constraints.size(); ++i)
	{
		// get constraint
		Constraint cons = constraints.get(i);
		int id1 = cons.id_ball_1;
		int id2 = cons.id_ball_2;
		// check if it has not been destroyed
		if(destroyed.get(id1) == 1 || destroyed.get(id2) == 1)
		{
			constraints.remove(i);
			i--;
			continue;
		}
		// get balls
		Ball ball1 = balls.get(id1);
		Ball ball2 = balls.get(id2);
		PVector pos1 = ball1.pos.copy();
		PVector pos2 = ball2.pos.copy();
		PVector disp = cons.displacement(pos1, pos2);
		// check constraint type
		if(constraints.get(i).type == ConstraintType.CLOSER_MERGE)
		{
			// check if applies
			if(disp.magSq() == 0) continue;
			// merge balls
			mergeBalls(ball1, ball2);
		}
		if(constraints.get(i).type == ConstraintType.CLOSER)
		{
			if(disp.mag() > EPS)
			{
				if(ball1.fixed)
					ball2.pos.sub(disp.mult(2.0));
				else if(ball2.fixed)
					ball1.pos.add(disp.mult(2.0));
				else
				{
					ball1.pos.add(disp);
					ball2.pos.sub(disp);
				}
			}
		}
		if(constraints.get(i).type == ConstraintType.FURTHER)
		{
			if(disp.mag() > EPS)
			{
				if(ball1.fixed)
					ball2.pos.sub(disp.mult(2.0));
				else if(ball2.fixed)
					ball1.pos.add(disp.mult(2.0));
				else
				{
					ball1.pos.add(disp);
					ball2.pos.sub(disp);
				}
			}
		}
	}
}

void draw()
{
	long begin = System.nanoTime();     

	if(carryingBall)
		pressedBall.pos = new PVector(mouseX, mouseY);

	processForces();

	long end = System.nanoTime();          
	long time = end-begin;
	System.out.println("Forces Elapsed Time: "+time / 1000000.0+"ms");
	begin = System.nanoTime(); 

	for(int jk=0; jk<JACOBIAN_COEF; ++jk)
	{
		processJacobian();
	}

	end = System.nanoTime();          
	time = end-begin;
	System.out.println("Jacobian Elapsed Time: "+time / 1000000.0+"ms");
	begin = System.nanoTime(); 
	
	for(Ball ball : balls.values())
	{
		ball.update();  
	}

	end = System.nanoTime();          
	time = end-begin;
	System.out.println("Update Elapsed Time: "+time / 1000000.0+"ms");
	begin = System.nanoTime(); 
	
	// -----------------------------------------------------------------
	// render
	// -----------------------------------------------------------------

	background(255);
	
	/*	
	for(Ball ball : balls.values())
	{
		ball.render();
	}
	*/

	end = System.nanoTime();          
	time = end-begin;
	System.out.println("Ball Render Elapsed Time: "+time / 1000000.0+"ms");
	begin = System.nanoTime(); 

	// iterate over every force to draw springs
	for(int i=0; i<forces.size(); ++i)
	{
		// get force
		Force force_o = forces.get(i);
		int id1 = force_o.id_ball_1;
		int id2 = force_o.id_ball_2;
		if(force_o.type != ForceType.SPRING) continue;
		// check if it has not been destroyed
		if(destroyed.get(id1) == 1 || destroyed.get(id2) == 1)
		{
			forces.remove(i);
			i--;
			continue;
		}
		Ball ball1 = balls.get(id1);
		Ball ball2 = balls.get(id2);
		PVector pos1 = ball1.pos.copy();
		PVector pos2 = ball2.pos.copy();
		// draw
		line(pos1.x, pos1.y, pos2.x, pos2.y);
	}
	
	end = System.nanoTime();          
	time = end-begin;
	System.out.println("Spring Render Elapsed Time: "+time / 1000000.0+"ms");

	/*
	if(pressed && !carryingBall)
	{
		line(pos_c1.x, pos_c1.y, mouseX, mouseY);
	}
	*/
	println("Frame Rate: "+frameRate);
}