import java.util.Map;

float STEP_SIZE = 1.0 / 100.0;
float VEL_COEF = 1.0 / 1.0;
float GRAV_COEF = 100000.0;
int JACOBIAN_COEF = 10;
float EPS = 1.0 / 10000.0;

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

void mousePressed()
{
	pos_c1 = new PVector(mouseX, mouseY);
}

void mouseReleased()
{
	if(pos_c1.x == -1)
		return;
	
	pos_c2.x = mouseX;
	pos_c2.y = mouseY;
	pos_c2.sub(pos_c1).mult(VEL_COEF);
	addBall(pos_c1.copy(), pos_c2.copy(), 1.0);
	pos_c1.x = -1;
}

void setup()
{
	pos_c1 = new PVector(-1, 0);
	pos_c2 = new PVector(-1, 0);
	ball_id = 0;
	
	fill(0);
	stroke(5);
	
	fullScreen();
	frameRate(60);
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
				ball1.pos.add(disp);
				ball2.pos.sub(disp);
			}
		}
	}
}

void draw()
{
	processForces();

	for(int jk=0; jk<JACOBIAN_COEF; ++jk)
	{
		processJacobian();
	}
	
	for(Ball ball : balls.values())
	{
		ball.update();  
	}
	
	// -----------------------------------------------------------------
	// render
	// -----------------------------------------------------------------
	background(255);
	
	for(Ball ball : balls.values())
	{
		ball.render();
	}

	// iterate over every force
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

	if(pos_c1.x != -1)
	{
		line(pos_c1.x, pos_c1.y, mouseX, mouseY);
	}
}